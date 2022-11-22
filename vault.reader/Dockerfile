FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["vault.reader/vault.reader.csproj", "vault.reader/"]
RUN dotnet restore "vault.reader/vault.reader.csproj"
COPY . .
WORKDIR "/src/vault.reader"
RUN dotnet build "vault.reader.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "vault.reader.csproj" -c Release -o /app/publish

FROM base AS final
COPY --from=publish /app/publish .

ENV DOTNET_EnableDiagnostics=0
ENV ASPNETCORE_URLS=http://+:8888

EXPOSE 8888
USER 1001

ENTRYPOINT ["dotnet", "vault.reader.dll"]