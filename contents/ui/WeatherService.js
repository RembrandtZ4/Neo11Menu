// Wetter-Hilfsfunktionen (Daten kommen von Open-Meteo, siehe WeatherCard.qml)

function getWeatherIcon(code) {
    code = parseInt(code);
    if (code < 3) return "weather-few-clouds";
    if (code < 50) return "weather-overcast";
    if (code < 70) return "weather-rain";
    if (code < 85) return "weather-snow";
    return "weather-thunderstorm";
}

function getWeatherDescription(code) {
    code = parseInt(code);
    if (code < 3) return "Klar";
    if (code < 5) return "Bewölkt";
    if (code < 50) return "Nebel";
    if (code < 70) return "Regen";
    if (code < 85) return "Schnee";
    return "Gewitter";
}

function readWeatherFile(callback) {
    // Reads weather data from D-Bus service
    console.log("[WeatherService] Attempting to read from D-Bus...");
    callback({
        temperature: "Lädt …",
        condition: "Lädt …",
        icon: "weather-clouds",
        success: false,
        useDBus: true
    });
}
