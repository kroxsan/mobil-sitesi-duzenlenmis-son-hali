using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using site_backend.Data;
using site_backend.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace site_backend.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class TicketsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TicketsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/tickets/my-tickets
        [HttpGet("my-tickets")]
        public async Task<ActionResult<IEnumerable<object>>> GetMyTickets()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var tickets = await _context.Tickets
                .Where(t => t.UserId == userId)
                .Include(t => t.Event)
                .Select(t => new
                {
                    t.Id,
                    t.PurchaseDate,
                    t.Quantity,
                    t.TotalPrice,
                    Event = new
                    {
                        t.Event!.Id,
                        t.Event.Name,
                        t.Event.Description,
                        t.Event.Category,
                        t.Event.City,
                        t.Event.Date,
                        t.Event.ImageUrl,
                        t.Event.Location,
                        t.Event.Price
                    }
                })
                .OrderByDescending(t => t.PurchaseDate)
                .ToListAsync();

            return Ok(tickets);
        }

        // POST: api/tickets
        [HttpPost]
        public async Task<ActionResult<object>> PurchaseTicket([FromBody] TicketPurchaseDto purchaseDto)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var ev = await _context.Events.FindAsync(purchaseDto.EventId);
            if (ev == null)
                return NotFound("Etkinlik bulunamadı");

            // 🔥 Kalan kapasite kontrolü
            var soldTickets = _context.Tickets
                .Where(t => t.EventId == ev.Id)
                .Sum(t => t.Quantity);

            var remainingCapacity = ev.Capacity - soldTickets;

            if (purchaseDto.Quantity > remainingCapacity)
                return BadRequest("Yeterli kapasite yok");

            var ticket = new Ticket
            {
                UserId = userId,
                EventId = purchaseDto.EventId,
                Quantity = purchaseDto.Quantity,
                TotalPrice = ev.Price * purchaseDto.Quantity,
                PurchaseDate = DateTime.UtcNow
            };

            _context.Tickets.Add(ticket);
            await _context.SaveChangesAsync();

            // Güncel kalan kapasiteyi frontend'e dönüyoruz
            return Created("", new
            {
                message = "Bilet satın alındı",
                eventData = new
                {
                    ev.Id,
                    ev.Name,
                    ev.Description,
                    ev.Category,
                    ev.City,
                    ev.Date,
                    ev.ImageUrl,
                    ev.Location,
                    ev.Price,
                    Capacity = remainingCapacity - purchaseDto.Quantity
                }
            });
        }

        // DELETE: api/tickets/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTicket(int id)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var ticket = await _context.Tickets
                .Where(t => t.Id == id && t.UserId == userId)
                .FirstOrDefaultAsync();

            if (ticket == null)
                return NotFound();

            _context.Tickets.Remove(ticket);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }

    public class TicketPurchaseDto
    {
        public int EventId { get; set; }
        public int Quantity { get; set; }
    }
}
