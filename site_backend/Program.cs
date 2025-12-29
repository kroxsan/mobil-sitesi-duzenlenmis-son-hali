using Microsoft.EntityFrameworkCore;
using site_backend.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// --- CORS Politikası ---              //flutter uygulamanın backend API’ya erişebilmesi için zorunlu olan güvenlik iznini veriyor
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb",
        policy => policy
            .AllowAnyOrigin()   // Geliştirme için, prod'da domain belirt
            .AllowAnyHeader()
            .AllowAnyMethod());
});

// --- Veritabanı Bağlantısı ---
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// --- JWT Ayarları ---
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters       //JWT token doğrulama parametreleri
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
        )
    };
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// --- Swagger JWT Desteği ---
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Token'ınızı 'Bearer {token}' formatında girin."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference 
                { 
                    Type = ReferenceType.SecurityScheme, 
                    Id = "Bearer" 
                }
            },
            new string[] {}
        }
    });
});

var app = builder.Build();

// --- Middleware Pipeline ---
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFlutterWeb");

// app.UseHttpsRedirection(); // Geliştirme aşamasında opsiyonel

app.UseAuthentication();       //Authentication = Token geçerli mi?
app.UseAuthorization();        //Authorization = Bu token bu endpoint’e girebilir mi?

app.MapControllers();

app.Run();
