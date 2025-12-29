using System.ComponentModel.DataAnnotations;

namespace site_backend.Models
{
    public class Event
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string Category { get; set; } = null!;
    public string City { get; set; } = null!;
    public double Price { get; set; }
    public DateTime Date { get; set; }
    public string ImageUrl { get; set; } = null!;
    public string Location { get; set; } = null!;
    public int Capacity { get; set; }

    public int UserId { get; set; }

    // Navigation property optional yap
    public User? User { get; set; }
}

}
