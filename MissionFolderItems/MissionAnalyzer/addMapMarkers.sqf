params ["_show"];

_addMapMarkers = {
    _m = "UnitMark";
    {
        _pos = getpos _x;
        _text = format["%1", typeof _x];
        _id = format["%1%2", _m, _forEachIndex + 1];
        createMarkerLocal[_id, _pos];
        _id setMarkerColorLocal "Default";
        _id setMarkerTypeLocal "hd_dot";
        _id setMarkerTextLocal _text;
        _id setMarkerSizeLocal[0.5, 0.5];
    } forEach entities[["Air", "Truck", "Car", "Motorcycle", "Tank", "StaticWeapon", "Ship"], [], false, true];
};

_removeMapMarkers = {
    _unitMarks = ["UnitMark"] call BIS_fnc_getMarkers;
    {
        deleteMarker _x;
    } forEach _unitMarks;
};

switch (_show) do {
    case true: {call _addMapMarkers};
    case false: {call _removeMapMarkers};
};