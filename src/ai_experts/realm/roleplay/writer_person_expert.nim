# Писатель который придумывает персонажа

import options
import json
import strformat
import sequtils

import ai_connector/openai_api/openai_api
import ai_connector/openai_api/structured_response
import ai_connector/common/text
import entity/person

type
    # Типы улучшений персонажа
    PersonEnchanceType* = enum
        # Автоматическое улучшение
        peAuto = 1 shl 0,
        # Имя
        peName = 1 shl 1,
        # Фамилия
        peSurname = 1 shl 2,
        # Возраст
        peAge = 1 shl 3,
        # Пол
        peSex = 1 shl 4,
        # Внешний вид
        peLook = 1 shl 5,
        # Характер
        peCharacter = 1 shl 6,
        # Мотивация
        peMotivation = 1 shl 7,
        # Предыстория
        peMemory = 1 shl 8    

    # Персонаж с отношениями
    PersonWithRelations* = object
        # Персонаж
        person*: Person
        # Отношения в произвольном виде: друг, враг, родственник, любовь
        relations*: Text

    # Модель для генерации текста
    WriterPersonExpert* = object
        # API
        api: OpenAiApi
        # Модель для генерации текста
        model: string

# Конструктор писателя который использует заданную модель
proc newWriterPersonExpert*(api: OpenAiApi, model: string): WriterPersonExpert =        
    return WriterPersonExpert(
        api: api,
        model: model
    )

# Генерация персонажа с нуля
# postPrompt - дополнительный промт для генерации персонажа который будет добавлен к основному промту в конце
proc generateRandomPerson*(writer: WriterPersonExpert, postPrompt: Option[Text]): Person =
    # Системный промт
    let systemPrompt = newText()
    # Пользовательский промт
    var userPrompt = newText()
    userPrompt.add("Придумай персонажа для ролевой игры.")
    userPrompt.add("Придумай имя(name) и фамилию(surname).")
    userPrompt.add("Возраст (age). Пол(sex).")
    userPrompt.add("Как выглядит(look).")
    userPrompt.add("Характер(character).")
    userPrompt.add("Мотивацию(motivation).")
    userPrompt.add("Предысторию персонажа(memory).")

    # Добавляем дополнительный промт
    if postPrompt.isSome():
        userPrompt.add(postPrompt.get())

    # Схема ответа
    let structuredResponse = generateJsonSchema(Person)

    let completeOptions = CompleteOptions(
        temperature: some(0.7),
        max_tokens: some(1000),
        stream: some(false),
        structuredResponse: some(structuredResponse)
    )    

    let completeResult = writer.api.complete(writer.model, systemPrompt, userPrompt, some(completeOptions))

    let jsonResult = parseJson(completeResult)
    let name = jsonResult["name"].getStr()
    let surname = jsonResult["surname"].getStr()
    let age = jsonResult["age"].getInt()
    let sex = jsonResult["sex"].getStr()
    let look = jsonResult["look"].getElems().mapIt(it.getStr())
    let character = jsonResult["character"].getElems().mapIt(it.getStr())
    let motivation = jsonResult["motivation"].getElems().mapIt(it.getStr())
    let memory = jsonResult["memory"].getElems().mapIt(it.getStr())
    return Person(
        name: name,
        surname: surname,
        age: age,
        sex: sex,
        look: look,
        character: character,
        motivation: motivation,
        memory: memory
    )

# Генерация персонажа с разными настройками
proc generateRandomPerson*(
        writer: WriterPersonExpert, 
        worldDescription: Option[Text],
        personWithRelations: Option[seq[PersonWithRelations]]): Person =   
    var userPrompt = newText()
    userPrompt.add("Персонаж должен вписываться в заданный мир:")
    if worldDescription.isSome():
        userPrompt.add(worldDescription.get())
    if personWithRelations.isSome():
        for personWithRelation in personWithRelations.get():
            userPrompt.add(personWithRelation.relations)
            
    return generateRandomPerson(writer, some(userPrompt))

# Улучшение персонажа
proc enchancePerson*(writer: WriterPersonExpert, person: Person, enchanceType: PersonEnchanceType): Person =
    result = person
    
    var userPrompt = newText()

    if enchanceType == peAuto:
        discard
        
    if len(person.name) > 0:
        userPrompt.add(fmt"Имя: {person.name}")

    if len(person.surname) > 0:
        userPrompt.add(fmt"Фамилия: {person.surname}")
    
    if person.age != 0:
        userPrompt.add(fmt"Возраст: {person.age}")

    if len(person.sex) > 0:
        userPrompt.add(fmt"Пол: {person.sex}")    
        
    if len(person.look) > 0:
        userPrompt.add(fmt"Внешний вид: {person.look}")

    if len(person.character) > 0:
        userPrompt.add(fmt"Характер: {person.character}")

    if len(person.motivation) > 0:
        userPrompt.add(fmt"Мотивация: {person.motivation}")

    if len(person.memory) > 0:
        userPrompt.add(fmt"Память: {person.memory}")

    userPrompt.add("Доработай персонажа для ролевой игры.")

    if (enchanceType.int and peName.int) != 0:
        userPrompt.add("Придумай имя(name).")

    if (enchanceType.int and peSurname.int) != 0:
        userPrompt.add("Придумай фамилию(surname).")

    if (enchanceType.int and peAge.int) != 0:
        userPrompt.add("Придумай возраст(age).")

    if (enchanceType.int and peSex.int) != 0:
        userPrompt.add("Придумай пол(sex).")

    if (enchanceType.int and peLook.int) != 0:
        userPrompt.add("Придумай внешний вид(look).")

    if (enchanceType.int and peCharacter.int) != 0:
        userPrompt.add("Придумай характер(character).")

    if (enchanceType.int and peMotivation.int) != 0:
        userPrompt.add("Придумай мотивацию(motivation).")

    if (enchanceType.int and peMemory.int) != 0:
        userPrompt.add("Придумай предысторию(memory).")
    
    let structuredResponse = generateJsonSchema(Person)

    let completeOptions = CompleteOptions(
        temperature: some(0.7),
        max_tokens: some(1000),
        stream: some(false),
        structuredResponse: some(structuredResponse)
    )    

    let completeResult = writer.api.complete(writer.model, @[], userPrompt, some(completeOptions))
    let jsonResult = parseJson(completeResult)    

    if (enchanceType.int and peName.int) != 0:
        result.name = jsonResult["name"].getStr()

    if (enchanceType.int and peSurname.int) != 0:
        result.surname = jsonResult["surname"].getStr()

    if (enchanceType.int and peAge.int) != 0:
        result.age = jsonResult["age"].getInt()

    if (enchanceType.int and peSex.int) != 0:
        result.sex = jsonResult["sex"].getStr()

    if (enchanceType.int and peLook.int) != 0:
        result.look = jsonResult["look"].getElems().mapIt(it.getStr())

    if (enchanceType.int and peCharacter.int) != 0:
        result.character = jsonResult["character"].getElems().mapIt(it.getStr())

    if (enchanceType.int and peMotivation.int) != 0:
        result.motivation = jsonResult["motivation"].getElems().mapIt(it.getStr())

    if (enchanceType.int and peMemory.int) != 0:
        result.memory = jsonResult["memory"].getElems().mapIt(it.getStr())
