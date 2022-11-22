using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();


app.UseSwagger();
app.UseSwaggerUI();

string keyVaultName = builder.Configuration.GetValue<string>("KEY_VAULT_NAME");
var kvUri = "https://" + keyVaultName + ".vault.azure.net";

builder.Configuration.AddAzureKeyVault(new Uri(kvUri), new DefaultAzureCredential());

app.MapGet("/get-secret/{key}", (string key, IConfiguration configuration) =>
{
    var value = configuration.GetValue<string>(key);

    var secretValue = new SecretValue(key, value);

    return secretValue;
})
.WithName("Secrets");

app.Run();

internal record SecretValue(string Key, string Value)
{      
      
}