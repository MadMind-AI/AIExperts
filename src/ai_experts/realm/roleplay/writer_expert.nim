# Писатель который придумывает истории

import options
import json
import strformat
import ai_connector/openai_api
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
    let userPrompt = newText()

    let structuredResponse =
            %* {
                "$schema": "http://json-schema.org/draft-07/schema#",
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Имя персонажа",
                        "minLength": 1
                    },
                    "surname": {
                        "type": "string",
                        "description": "Фамилия персонажа",
                        "minLength": 1
                    },
                    "age": {
                        "type": "integer",
                        "description": "Возраст персонажа",
                        "minimum": 0
                    },
                    "sex": {
                        "type": "string",
                        "description": "Пол персонажа",
                        "enum": [
                            "Мужской",
                            "Женский",
                            "Другое"
                        ]
                    },
                    "look": {
                        "type": "string",
                        "description": "Описание внешности персонажа",
                        "minLength": 1
                    },
                    "character": {
                        "type": "string",
                        "description": "Описание характера персонажа",
                        "minLength": 1
                    },
                    "motivation": {
                        "type": "string",
                        "description": "Мотивация персонажа",
                        "minLength": 1
                    },
                    "memory": {
                        "type": "string",
                        "description": "Предыстория персонажа",
                        "minLength": 1
                    }
                },
                "required": [
                    "name",
                    "surname",
                    "age",
                    "sex",
                    "look",
                    "character",
                    "motivation",
                    "memory"
                ],
                "additionalProperties": false
            }
        
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
    let look = jsonResult["look"].getStr()
    let character = jsonResult["character"].getStr()
    return Person(
        name: fmt"{name} {surname}",
        age: age,
        sex: sex,
        look: newText(look),
        character: newText(character),
        motivation: newText(""),
        memory: newText("")
    )
