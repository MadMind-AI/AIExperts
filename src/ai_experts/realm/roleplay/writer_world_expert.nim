# Писатель который придумывает мир

import options
import json
import strformat
import sequtils
import ai_connector/common/text

import ai_connector/openai_api/openai_api
import entity/world
import entity/area
import entity/location

type
    # Базовые настройки генерации мира
    BaseWorldGeneratorSettings* = object of RootObj
        # Тип мира
        worldType*: WorldType

    # Настройки генерации реального мира
    RealWorldGeneratorSettings* = object of BaseWorldGeneratorSettings
        # Природные особенности мира
        natureFeatures*: Text
        # Политические особенности мира
        politicalFeatures*: Text
        # Экономические особенности мира
        economicFeatures*: Text
        # Социальные особенности мира
        socialFeatures*: Text
        # Конфликты в мире
        conflicts*: Text

    # Писатель мира
    WriterWorldExpert* = object
        # API
        api: OpenAiApi
        # Модель для генерации текста
        model: string

# Генерирует системный промт для генерации реального мира
proc realWorldGeneratorPrompt*(settings: RealWorldGeneratorSettings): Text =
    var prompt = newText()
    prompt.add("Придумай мир для ролевой игры на основе нашего реального мира в текущем времени.")
    if settings.natureFeatures.len > 0:
        prompt.add("Природные особенности мира: " & settings.natureFeatures)
    if settings.politicalFeatures.len > 0:
        prompt.add("Политические особенности мира: " & settings.politicalFeatures)
    if settings.economicFeatures.len > 0:
        prompt.add("Экономические особенности мира: " & settings.economicFeatures)
    if settings.socialFeatures.len > 0:
        prompt.add("Социальные особенности мира: " & settings.socialFeatures)
    if settings.conflicts.len > 0:
        prompt.add("Конфликты в мире: " & settings.conflicts)
    return prompt

# Создает новый писатель мира
proc newWriterWorldExpert*(api: OpenAiApi, model: string): WriterWorldExpert =
    return WriterWorldExpert(
        api: api,
        model: model
    )

# Генерирует случайный мир без областей
proc generateRandomWorld*(
        writer: WriterWorldExpert        
    ): World =    
    # Пользовательский промт
    var userPrompt = newText()
    userPrompt.add("Придумай мир для ролевой игры.")    

    let completeOptions = CompleteOptions(
        temperature: some(0.7),
        max_tokens: some(1000),
        stream: some(false)
    ) 

    let completeResult = writer.api.complete(writer.model, newText(), userPrompt, some(completeOptions))

    return newWorld(
        completeResult,
        @[]
    )
    
# Генерирует случайный реальный мир
proc generateRandomWorld*(writer: WriterWorldExpert, settings: RealWorldGeneratorSettings): World =
    var userPrompt = newText()
    userPrompt.add("Придумай мир для ролевой игры на основе нашего реального мира в текущем времени.")
    if settings.natureFeatures.len > 0:
        userPrompt.add("Природные особенности мира: " & settings.natureFeatures)
    if settings.politicalFeatures.len > 0:
        userPrompt.add("Политические особенности мира: " & settings.politicalFeatures)
    if settings.economicFeatures.len > 0:
        userPrompt.add("Экономические особенности мира: " & settings.economicFeatures)
    if settings.socialFeatures.len > 0:
        userPrompt.add("Социальные особенности мира: " & settings.socialFeatures)
    if settings.conflicts.len > 0:
        userPrompt.add("Конфликты в мире: " & settings.conflicts)

    let completeOptions = CompleteOptions(
        temperature: some(0.7),
        max_tokens: some(1000),
        stream: some(false)
    ) 

    let completeResult = writer.api.complete(writer.model, newText(), userPrompt, some(completeOptions))

    return newWorld(
        completeResult,
        @[]
    )

# Генерирует области в мире
proc generateWorldAreas*(writer: WriterWorldExpert, world: World): seq[Area] =
    return @[]

# Генерирует локации в области
proc generateAreaLocations*(writer: WriterWorldExpert, area: Area): seq[Location] =
    return @[]
