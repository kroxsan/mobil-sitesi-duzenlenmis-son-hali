namespace site_backend.Models
{
    public class Ticket
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int EventId { get; set; }
        public DateTime PurchaseDate { get; set; }
        public int Quantity { get; set; }
        public double TotalPrice { get; set; }

        // Navigation properties
        public User? User { get; set; }
        public Event? Event { get; set; }
    }
}
