# Писатель который придумывает истории

import options
import json
import strformat
import sequtils

import ai_connector/openai_api/openai_api
import ai_connector/openai_api/structured_response
import ai_connector/common/text
import entity/person

type
    # Модель для генерации текста
    WriterExpert* = object
        # API
        api: OpenAiApi
        # Модель для генерации текста
        model: string

# Конструктор писателя который использует заданную модель
proc newWriterExpert*(api: OpenAiApi, model: string): WriterExpert =        
    return WriterExpert(
        api: api,
        model: model
    )

# Генерация персонажа с нуля
proc generatePerson*(writer: WriterExpert): Person =
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
        name: fmt"{name} {surname}",
        age: age,
        sex: sex,
        look: look,
        character: character,
        motivation: motivation,
        memory: memory
    )
