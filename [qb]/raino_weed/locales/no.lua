local Translations = {
    error = {
        process_canceled = "Prosessen kansellert",
        plant_has_died = "Planten har dødd. Trykk ~r~ E ~w~ for og fjerne planten.",
        cant_place_here = "Kan ikke plassere her",
        not_safe_here = "Det er ikke trygt her, prøv i huset ditt",
        not_need_nutrition = "Planten trenger ikke ernæring",
        this_plant_no_longer_exists = "Denne planten eksisterer ikke lenger?",
        house_not_found = "Hus ikke funnet",
        you_dont_have_enough_resealable_bags = "Du har ikke nok gjenlukkbare poser",
    },
    text = {
        sort = 'Sortere:',
        harvest_plant = 'Trykk ~g~ E ~w~ å høste plante.',
        nutrition = "Ernæring:",
        health = "Helse:",
        harvesting_plant = "Høster plante",
        planting = "Planter",
        feeding_plant = "Vanner planten",
        the_plant_has_been_harvested = "Planten er høstet",
        removing_the_plant = "Fjerner plante",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
