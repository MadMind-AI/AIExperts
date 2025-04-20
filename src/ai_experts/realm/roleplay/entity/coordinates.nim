# Тип для координат
type Coordinates* = object
    # Широта
    latitude*: float
    # Долгота
    longitude*: float

# Создает новые координаты
proc newCoordinates*(latitude:float, longitude:float): Coordinates =
    result = Coordinates(latitude: latitude, longitude: longitude)