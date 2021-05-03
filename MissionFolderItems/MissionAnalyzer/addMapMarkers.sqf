_m = "aa%1"; {
    _pos = getpos _x;
    _text = format["%1", typeof _x];
    _id = format[_m, _forEachIndex];
    createMarkerLocal[_id, _pos];
    _id setMarkerColorLocal "Default";
    _id setMarkerTypeLocal "hd_dot";
    _id setMarkerTextLocal _text;
    _id setMarkerSizeLocal[0.5, 0.5];
} forEach entities "all";