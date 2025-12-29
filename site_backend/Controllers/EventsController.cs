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
    public class EventsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EventsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/events
        [AllowAnonymous]
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetEvents()
        {
            var events = await _context.Events
                .Select(e => new
                {
                    e.Id,
                    e.Name,
                    e.Description,
                    e.Category,
                    e.City,
                    e.Price,
                    e.Date,
                    e.ImageUrl,
                    e.Location,

                    // Kalan kapasiteyi burada hesaplıyoruz
                    Capacity = e.Capacity - _context.Tickets
                        .Where(t => t.EventId == e.Id)
                        .Sum(t => t.Quantity)
                })
                .ToListAsync();

            return Ok(events);
        }

        // GET: api/events/5
        [AllowAnonymous]
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetEvent(int id)
        {
            var ev = await _context.Events
                .Where(e => e.Id == id)
                .Select(e => new
                {
                    e.Id,
                    e.Name,
                    e.Description,
                    e.Category,
                    e.City,
                    e.Price,
                    e.Date,
                    e.ImageUrl,
                    e.Location,

                    Capacity = e.Capacity - _context.Tickets
                        .Where(t => t.EventId == e.Id)
                        .Sum(t => t.Quantity)
                })
                .FirstOrDefaultAsync();

            if (ev == null)
                return NotFound();

            return Ok(ev);
        }

        // POST: api/events
        [HttpPost]
        public async Task<ActionResult<Event>> CreateEvent(Event ev)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            ev.UserId = userId;
            
            // DateTime'ı UTC'ye çevir
            if (ev.Date.Kind == DateTimeKind.Unspecified)
            {
                ev.Date = DateTime.SpecifyKind(ev.Date, DateTimeKind.Utc);
            }

            _context.Events.Add(ev);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetEvent), new { id = ev.Id }, ev);
        }

        // PUT: api/events/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEvent(int id, Event ev)
        {
            if (id != ev.Id)
                return BadRequest();

            var existingEvent = await _context.Events.FindAsync(id);

            if (existingEvent == null)
                return NotFound();

            existingEvent.Name = ev.Name;
            existingEvent.Description = ev.Description;
            existingEvent.Category = ev.Category;
            existingEvent.City = ev.City;
            existingEvent.Price = ev.Price;
            
            // DateTime'ı UTC'ye çevir
            existingEvent.Date = ev.Date.Kind == DateTimeKind.Unspecified 
                ? DateTime.SpecifyKind(ev.Date, DateTimeKind.Utc) 
                : ev.Date.ToUniversalTime();
            
            existingEvent.ImageUrl = ev.ImageUrl;
            existingEvent.Location = ev.Location;
            existingEvent.Capacity = ev.Capacity;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!EventExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/events/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEvent(int id)
        {
            var ev = await _context.Events.FindAsync(id);

            if (ev == null)
                return NotFound();

            _context.Events.Remove(ev);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        private bool EventExists(int id)
        {
            return _context.Events.Any(e => e.Id == id);
        }
    }
}