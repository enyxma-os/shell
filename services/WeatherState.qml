pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    // Kullanıcı Tercihleri
    property bool useCelsius: true
    property string city: "İzmir"

    // Canlı Hava Durumu Parametreleri
    property int tempC: 17
    property int feelsLikeC: 14
    property int humidity: 42
    property int windSpeed: 12
    property string windDir: "KB"
    property int rainProb: 0
    property string rawCondition: "Sunny"
    readonly property string conditionText: {
        var _l = I18n.lang;
        return root.translateDesc(root.rawCondition);
    }
    property string conditionGlyph: "☀️"
    property bool isDay: true
    property bool isLoading: false
    property string lastUpdated: ""

    // Saatlik Tahmin Listesi (Default/Fallback şablonu)
    property var hourlyForecast: [
        { time: "18:00", temp: 17, glyph: "☀️", pop: 0, desc: "Açık" },
        { time: "20:00", temp: 15, glyph: "🌙", pop: 0, desc: "Açık" },
        { time: "22:00", temp: 14, glyph: "🌙", pop: 5, desc: "Açık" },
        { time: "00:00", temp: 13, glyph: "🌙", pop: 5, desc: "Açık" },
        { time: "02:00", temp: 12, glyph: "🌙", pop: 10, desc: "Açık" },
        { time: "04:00", temp: 11, glyph: "🌙", pop: 10, desc: "Açık" }
    ]

    // Görüntüleme Getter'ları
    readonly property string displayTemp: {
        if (useCelsius) return tempC + "°C";
        return Math.round(tempC * 9 / 5 + 32) + "°F";
    }

    readonly property string displayFeels: {
        if (useCelsius) return feelsLikeC + "°";
        return Math.round(feelsLikeC * 9 / 5 + 32) + "°";
    }

    function formatTemp(c) {
        if (useCelsius) return c + "°";
        return Math.round(c * 9 / 5 + 32) + "°";
    }

    function toggleUnit() {
        useCelsius = !useCelsius;
    }

    function translateDesc(desc) {
        const d = (desc || "").toLowerCase();
        if (d.includes("sunny")) return I18n.t("Güneşli", "Sunny");
        if (d.includes("clear")) return isDay ? I18n.t("Açık", "Clear") : I18n.t("Açık Gece", "Clear Night");
        if (d.includes("partly cloudy")) return I18n.t("Parçalı Bulutlu", "Partly Cloudy");
        if (d.includes("cloudy") || d.includes("overcast")) return I18n.t("Bulutlu", "Cloudy");
        if (d.includes("rain") || d.includes("drizzle")) return I18n.t("Yağmurlu", "Rainy");
        if (d.includes("thunder")) return I18n.t("Gök Gürültülü", "Thunderstorm");
        if (d.includes("snow") || d.includes("sleet")) return I18n.t("Karlı", "Snowy");
        if (d.includes("fog") || d.includes("mist")) return I18n.t("Sisli", "Foggy");
        return desc || I18n.t("Açık", "Clear");
    }

    function glyphFor(desc, dayTime) {
        const d = (desc || "").toLowerCase();
        if (d.includes("sunny")) return "☀️";
        if (d.includes("clear")) return dayTime ? "☀️" : "🌙";
        if (d.includes("partly cloudy")) return dayTime ? "⛅" : "☁️";
        if (d.includes("cloudy") || d.includes("overcast")) return "☁️";
        if (d.includes("rain") || d.includes("drizzle")) return "🌧️";
        if (d.includes("thunder")) return "⛈️";
        if (d.includes("snow") || d.includes("sleet")) return "❄️";
        if (d.includes("fog") || d.includes("mist")) return "🌫️";
        return dayTime ? "☀️" : "🌙";
    }

    function parseWeather(jsonStr) {
        try {
            const data = JSON.parse(jsonStr);
            if (!data || !data.current_condition || data.current_condition.length === 0) return;

            const curr = data.current_condition[0];
            root.tempC = parseInt(curr.temp_C) || root.tempC;
            root.feelsLikeC = parseInt(curr.FeelsLikeC) || root.feelsLikeC;
            root.humidity = parseInt(curr.humidity) || root.humidity;
            root.windSpeed = parseInt(curr.windspeedKmph) || root.windSpeed;
            root.windDir = curr.winddir16Point || (I18n.isEn ? "NW" : "KB");
            root.rainProb = parseInt(curr.precipMM > 0 ? 80 : 0);

            const rawDesc = (curr.weatherDesc && curr.weatherDesc[0]) ? curr.weatherDesc[0].value : "Clear";
            const nowHour = new Date().getHours();
            root.isDay = (nowHour >= 6 && nowHour < 19);
            root.rawCondition = rawDesc;
            root.conditionGlyph = root.glyphFor(rawDesc, root.isDay);

            // Saatlik Tahminleri İşle
            if (data.weather && data.weather[0] && Array.isArray(data.weather[0].hourly)) {
                const list = [];
                const hours = data.weather[0].hourly;
                for (let i = 0; i < hours.length; i++) {
                    const h = hours[i];
                    const rawTime = parseInt(h.time) / 100;
                    const timeLabel = (rawTime < 10 ? "0" + rawTime : String(rawTime)) + ":00";
                    const hTemp = parseInt(h.tempC) || 0;
                    const hDesc = (h.weatherDesc && h.weatherDesc[0]) ? h.weatherDesc[0].value : "Clear";
                    const hIsDay = (rawTime >= 6 && rawTime < 19);
                    const hPop = parseInt(h.chanceofrain) || 0;

                    list.push({
                        time: timeLabel,
                        temp: hTemp,
                        glyph: root.glyphFor(hDesc, hIsDay),
                        pop: hPop,
                        desc: root.translateDesc(hDesc)
                    });
                }
                if (list.length > 0) {
                    root.hourlyForecast = list;
                }
            }

            const now = new Date();
            root.lastUpdated = (now.getHours() < 10 ? "0" + now.getHours() : now.getHours()) + ":" + (now.getMinutes() < 10 ? "0" + now.getMinutes() : now.getMinutes());
        } catch (e) {
            // Sessiz hata yakalama: mevcut değerleri koru
        } finally {
            root.isLoading = false;
        }
    }

    function fetchWeather() {
        if (root.isLoading) return;
        root.isLoading = true;
        weatherProcess.running = true;
    }

    Process {
        id: weatherProcess
        command: ["curl", "-s", "--max-time", "5", "https://wttr.in/" + encodeURIComponent(root.city) + "?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseWeather(this.text);
            }
        }
    }

    // 30 dakikada bir otomatik tazeleme
    Timer {
        interval: 1800000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchWeather()
    }
}
