import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Application;

class InfoWeather extends WatchUi.Drawable {
    private var color = Graphics.COLOR_BLACK;

    function initialize(params) {
        Drawable.initialize(params);
        self.color = params.get(:color);
    }

    function draw(dc as Dc) {
        Drawable.draw(dc);

        self.drawWeatherIcon(dc, self.locX + width * 0.10, self.locY, self.locX, self.color);
        self.drawTemperature(dc, self.locX - 24, self.locY + 28, false, self.color);
    }

    function drawWeatherIcon(dc, x, y, x2, fontColor) {
        var weather = Toybox.Weather.getCurrentConditions();
        if (weather == null) {
            return false;
        }
        var cond = weather.condition;
        var sunset, sunrise;

        if (cond != null and cond instanceof Number) {
            var clockTime = System.getClockTime().hour;
            var WeatherFont = Application.loadResource(Rez.Fonts.WeatherFont);

            // gets the correct symbol (sun/moon) depending on actual sun events
            var position =
                Toybox.Weather.getCurrentConditions()
                    .observationLocationPosition;  // or
                                                // Activity.Info.currentLocation
                                                // if observation is null?
            var today =
                Toybox.Weather.getCurrentConditions()
                    .observationTime;  // or new Time.Moment(Time.now().value()); ?

            if (position != null and today != null) {
                if (Weather.getSunset(position, today) != null) {
                    sunset = Time.Gregorian.info(Weather.getSunset(position, today),
                                                Time.FORMAT_SHORT);
                    sunset = sunset.hour;
                } else {
                    sunset = 18;
                }
                if (Weather.getSunrise(position, today) != null) {
                    sunrise = Time.Gregorian.info(Weather.getSunrise(position, today),
                                                Time.FORMAT_SHORT);
                    sunrise = sunrise.hour;
                } else {
                    sunrise = 6;
                }
            } else {
                sunset = 18;
                sunrise = 6;
            }

            // weather icon test
            // weather.condition = 6;

            dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
            if (cond == 20) {  // Cloudy
                dc.drawText(x2 - 1, y - 1, WeatherFont, "I",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Cloudy
            } else if (cond == 0 or cond == 5) {         // Clear or Windy
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2 - 2, y - 1, WeatherFont, "f",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Clear Night
                } else {
                dc.drawText(x2, y - 2, WeatherFont, "H",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Clear Day
                }
            } else if (cond == 1 or cond == 23 or cond == 40 or
                        cond == 52) {  // Partly Cloudy or Mostly Clear or fair or thin
                                        // clouds
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2 - 1, y - 2, WeatherFont, "g",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Partly Cloudy Night
                } else {
                dc.drawText(x2, y - 2, WeatherFont, "G",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Partly Cloudy Day
                }
            } else if (cond == 2 or cond == 22) {  // Mostly Cloudy or Partly Clear
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2, y, WeatherFont, "h",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Mostly Cloudy Night
                } else {
                dc.drawText(x, y, WeatherFont, "B",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Mostly Cloudy Day
                }
            } else if (cond == 3 or cond == 14 or cond == 15 or cond == 11 or
                        cond == 13 or cond == 24 or cond == 25 or cond == 26 or
                        cond == 27 or
                        cond == 45) {  // Rain or Light Rain or heavy rain or showers
                                        // or unkown or chance
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2, y, WeatherFont, "c",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Rain Night
                } else {
                dc.drawText(x, y, WeatherFont, "D",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Rain Day
                }
            } else if (cond == 4 or cond == 10 or cond == 16 or cond == 17 or
                        cond == 34 or cond == 43 or cond == 46 or cond == 48 or
                        cond ==
                            51) {  // Snow or Hail or light or heavy snow or ice or
                                    // chance or cloudy chance or flurries or ice snow
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2, y, WeatherFont, "e",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Snow Night
                } else {
                dc.drawText(x, y, WeatherFont, "F",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Snow Day
                }
            } else if (cond == 6 or cond == 12 or cond == 28 or cond == 32 or
                        cond == 36 or cond == 41 or
                        cond == 42) {  // Thunder or scattered or chance or tornado or
                                        // squall or hurricane or tropical storm
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2, y, WeatherFont, "b",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Thunder Night
                } else {
                dc.drawText(x, y, WeatherFont, "C",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Thunder Day
                }
            } else if (cond == 7 or cond == 18 or cond == 19 or cond == 21 or
                        cond == 44 or cond == 47 or cond == 49 or
                        cond == 50) {  // Wintry Mix (Snow and Rain) or chance or
                                        // cloudy chance or freezing rain or sleet
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2, y, WeatherFont, "d",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Snow+Rain Night
                } else {
                dc.drawText(x, y, WeatherFont, "E",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Snow+Rain Day
                }
            } else if (cond == 8 or cond == 9 or cond == 29 or cond == 30 or
                        cond == 31 or cond == 33 or cond == 35 or cond == 37 or
                        cond == 38 or
                        cond == 39) {  // Fog or Hazy or Mist or Dust or Drizzle or
                                        // Smoke or Sand or sandstorm or ash or haze
                if (clockTime >= sunset or clockTime < sunrise) {
                dc.drawText(x2, y, WeatherFont, "a",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Fog Night
                } else {
                dc.drawText(x, y, WeatherFont, "A",
                            Graphics.TEXT_JUSTIFY_RIGHT);  // Fog Day
                }
            }
            return true;
        } else {
            return false;
        }
    }

  function drawTemperature(dc, x, y, showBoolean, fontColor) {
    var TempMetric = System.getDeviceSettings().temperatureUnits;
    var temp = null, units = "", minTemp = null, maxTemp = null;
    var weather = Weather.getCurrentConditions();
    if (weather == null) {
      return;
    }

    if ((weather.lowTemperature != null) and (weather.highTemperature != null)) {
        // and weather.lowTemperature instanceof Number ;  and
        // weather.highTemperature instanceof Number
      minTemp = weather.lowTemperature;
      maxTemp = weather.highTemperature;
    }

    var offset = 0;

    if (showBoolean == false and
        (weather.feelsLikeTemperature !=
         null)) {  // feels like ;  and weather.feelsLikeTemperature instanceof
                   // Number
      if (TempMetric == System.UNIT_METRIC or
          Storage.getValue(16) == true) {  // Celsius
        units = "°C";
        temp = weather.feelsLikeTemperature;
      } else {
        temp = (weather.feelsLikeTemperature * 9 / 5) + 32;
        if (minTemp != null and maxTemp != null) {
          minTemp = (minTemp * 9 / 5) + 32;
          maxTemp = (maxTemp * 9 / 5) + 32;
        }
        // temp = Lang.format("$1$", [temp.format("%d")] );
        units = "°F";
      }
    } else if ((weather.temperature != null)) {
      // real temperature ;  and weather.temperature
      // instanceof Number
      if (TempMetric == System.UNIT_METRIC or
          Storage.getValue(16) == true) {  // Celsius
        units = "°C";
        temp = weather.temperature;
      } else {
        temp = (weather.temperature * 9 / 5) + 32;
        if (minTemp != null and maxTemp != null) {
          minTemp = (minTemp * 9 / 5) + 32;
          maxTemp = (maxTemp * 9 / 5) + 32;
        }
        // temp = Lang.format("$1$", [temp.format("%d")] );
        units = "°F";
      }
    }

    if (temp != null) {  // and temp instanceof Number
      dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
      if ((minTemp != null) and
          (maxTemp != null)) {  //  and minTemp instanceof Number ;  and maxTemp
                                //  instanceof Number
        if (temp <= minTemp) {
          if (fontColor == Graphics.COLOR_WHITE) {  // Dark Theme
            dc.setColor(Graphics.COLOR_BLUE,
                        Graphics.COLOR_TRANSPARENT);  // Light Blue 0x55AAFF
          } else {                                    // Light Theme
            dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT);
          }
        } else if (temp >= maxTemp) {
          if (fontColor == Graphics.COLOR_WHITE) {              // Dark Theme
            dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);  // Light Orange
          } else {                                              // Light Theme
            dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
          }
        }
      }

      // correcting a bug introduced by System 7 SDK
      temp = temp.format("%d");

      dc.drawText(x, y + offset, Graphics.FONT_XTINY, temp,
                  Graphics.TEXT_JUSTIFY_LEFT);  // + units
      dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x + dc.getTextWidthInPixels(temp, Graphics.FONT_XTINY),
                  y + offset, Graphics.FONT_XTINY, units,
                  Graphics.TEXT_JUSTIFY_LEFT);
    }
  }
}
