var locales = {
  "en": {
    "": {
      "domain": "test",
      "lang": "en",
      "plural_forms": "nplurals=2; plural=(n != 1);"
    },
    "label_first_field": [null, "The First Field"],
    "label_second_field": [null, "The Second Field"],
    "label_third_field": [null, "The Third Field"]
  },
  "fr": {
    "": {
      "domain": "test",
      "lang": "fr",
      "plural_forms": "nplurals=2; plural=(n != 1);"
    },
    "label_first_field": [null, "Le champ premier"],
    "label_second_field": [null, "Le champ deuxième"],
    "label_third_field": [null, "Le champ troisième"]
  }
}

function getI18nInstance(locale) {
  var i18n = new Jed({
    "domain": "test",
    "locale_data": {
      "test": locales[locale]
    }
  });

  return i18n;
}

$(function() {
  $("#locale").change(function() {
    var i18n = getI18nInstance($(this).val());
    $('[data-i18n]').each(function() {
      var key = $(this).attr('data-i18n'),
          value = i18n.translate(key).fetch();
      console.log(key, value)
      $(this).text(value);
    });
  }).change();
});
