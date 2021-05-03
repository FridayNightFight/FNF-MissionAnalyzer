private[
    "_date",
    "_time",
    "_viewDistance",
    "_overcast",
    "_overcastForecast",
    "_fog",
    "_fogForecast",
    "_rain",
    "_humidity",
    "_windDir",
    "_windStr",
    "_gusts"
];

// _ddMMyyyy
_curDate = date;
_date = format["%1-%2-%3",
    _curDate select 0,
    (
        if (_curDate select 1 < 10) then {
            "0"
        } else {
            ""
        }) + str(_curDate select 1),
    (
        if (_curDate select 2 < 10) then {
            "0"
        } else {
            ""
        }) + str(_curDate select 2)
];

_time = [daytime, "HH:MM"] call BIS_fnc_timeToString;
_viewDistance = viewDistance;
_overcast = overcast;
_overcastForecast = overcastForecast;
_fog = fog;
_fogForecast = fogForecast;
_rain = rain;
_humidity = humidity;
_windDir = windDir;
_windStr = windStr;
_gusts = gusts;



private _output = [
    _date,
    _time,
    _viewDistance,
    _overcast,
    _overcastForecast,
    _fog,
    _fogForecast,
    _rain,
    _humidity,
    _windDir,
    _windStr,
    _gusts
] joinString '|';
"debug_console"
callExtension(_output + "~0000");
"debug_console"
callExtension("X");