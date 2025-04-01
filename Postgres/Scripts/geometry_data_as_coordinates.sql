select place,
    ST_X(place),
    ST_Y(place),
    ST_AsText(place),
    ST_GeometryType(place),
    ST_SRID(place)
from table;
