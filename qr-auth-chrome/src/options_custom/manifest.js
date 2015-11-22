this.manifest = {
    "name": "QR Auth",
    "icon": "icon.png",
    "settings": [
        {
            "tab": i18n.get("information"),
            "group": i18n.get("login"),
            "name": "username",
            "type": "text",
            "label": i18n.get("username"),
            "text": i18n.get("x-characters")
        },
        {
            "tab": i18n.get("information"),
            "group": i18n.get("login"),
            "name": "password",
            "type": "text",
            "label": i18n.get("password"),
            "text": i18n.get("x-characters-pw"),
            "masked": true
        },
        {
            "tab": i18n.get("information"),
            "group": i18n.get("login"),
            "name": "myDescription",
            "type": "description",
            "text": i18n.get("description")
        },
        {
            "tab": i18n.get("information"),
            "group": i18n.get("login"),
            "name": "loginButton",
            "type": "button",
            "label": i18n.get("disconnect"),
            "text": i18n.get("login")
        },
    ],
    "alignment": [
        [
            "username",
            "password"
        ]
    ]
};
