import strformat

import ai_connector/common/text

# Тип для видов действий персонажа
type PersonActionKind* = enum
    # Действие, которое требует ответа от игрока
    talk
    # Действие за исключением разговора, передвижения, сна
    action
    # Действие передвижения
    move
    # Действие сна
    sleep

# Тип для действий персонажа
type PersonAction* = object
    case kind: PersonActionKind    
    of PersonActionKind.talk:
        talk: string    
    of PersonActionKind.action:
        action: string
    of PersonActionKind.move:
        move: string
    of PersonActionKind.sleep:
        sleep: string

# Тип персонажа
type Person* = object
    # Является ли персонаж главным
    isMain*: bool
    # Имя персонажа
    name*: string
    # Фамилия персонажа
    surname*: string
    # Пол персонажа
    sex*: string
    # Возраст персонажа
    age*: int
    # Внешность персонажа
    look*: Text
    # Характеристики персонажа
    character*: Text
    # Мотивация персонажа: инстинкты, желания, цели
    motivation*: Text
    # Память персонажа
    memory*: Text

# Персонаж с действиями
type PersonWithActions* = object
    # Персонаж
    person*: Person
    # Действия персонажа
    actions*: seq[PersonAction]

# Создает нового персонажа
proc newPerson*(
        isMain:bool,
        name:string, 
        surname:string,
        sex:string,
        age:int, 
        look:Text,
        character:Text, 
        motivation:Text, 
        memory:Text):Person =
    result = Person(
        isMain: isMain,
        name: name, 
        surname: surname,
        sex: sex,
        age: age, 
        look: look,
        character: character, 
        motivation: motivation, 
        memory: memory)

# Получает полное имя персонажа
proc getFullName*(person: Person): string =
    return fmt"{person.name} {person.surname}"

# Оператор для вывода персонажа в виде строки
proc `$`*(person: Person): string =
    var txt = newText()
    txt.add(fmt"{getFullName(person)}")
    txt.add(fmt"Пол: {person.sex} Возраст: {person.age}")
    txt.add(fmt"Внешность: {person.look}")
    txt.add(fmt"Характер: {person.character}")
    txt.add(fmt"Мотивация: {person.motivation}")
    txt.add(fmt"Память: {person.memory}")
    return txt.toString()

# Создает нового персонажа с действиями
proc newPersonWithActions*(person: Person, actions: seq[PersonAction]): PersonWithActions =
    result = PersonWithActions(person: person, actions: actions)
