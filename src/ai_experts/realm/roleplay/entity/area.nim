import strformat

import location

# Тип для области
type Area* = object
    # Имя области
    name*: string
    # Описание области
    description*: string
    # Под-области. Например: область может состоять из нескольких районов, в районах могут быть города, в городах могут быть улицы
    areas*: seq[Area]
    # Местоположения в области которые можно посетить
    locations*: seq[Location]

# Оператор для вывода области
proc `$`*(area: Area): string =
    return fmt"Область: {area.name} {area.description} {area.locations}"

# Создает новую область
proc newArea*(name:string, description:string, locations:seq[Location]): Area =
    result = Area(name: name, description: description, locations: locations)

