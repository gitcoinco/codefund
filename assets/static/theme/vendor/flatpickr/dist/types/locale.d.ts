export declare type Locale = {
    weekdays: {
        shorthand: [string, string, string, string, string, string, string];
        longhand: [string, string, string, string, string, string, string];
    };
    months: {
        shorthand: [string, string, string, string, string, string, string, string, string, string, string, string];
        longhand: [string, string, string, string, string, string, string, string, string, string, string, string];
    };
    daysInMonth: [number, number, number, number, number, number, number, number, number, number, number, number];
    firstDayOfWeek: number;
    ordinal: (nth: number) => string;
    rangeSeparator: string;
    weekAbbreviation: string;
    scrollTitle: string;
    toggleTitle: string;
    amPM: [string, string];
    yearAriaLabel: string;
};
export declare type CustomLocale = {
    ordinal?: Locale["ordinal"];
    daysInMonth?: Locale["daysInMonth"];
    firstDayOfWeek?: Locale["firstDayOfWeek"];
    rangeSeparator?: Locale["rangeSeparator"];
    weekAbbreviation?: Locale["weekAbbreviation"];
    toggleTitle?: Locale["toggleTitle"];
    scrollTitle?: Locale["scrollTitle"];
    yearAriaLabel?: string;
    amPM?: Locale["amPM"];
    weekdays: {
        shorthand: [string, string, string, string, string, string, string];
        longhand: [string, string, string, string, string, string, string];
    };
    months: {
        shorthand: [string, string, string, string, string, string, string, string, string, string, string, string];
        longhand: [string, string, string, string, string, string, string, string, string, string, string, string];
    };
};
export declare type key = "ar" | "at" | "be" | "bg" | "bn" | "cat" | "cs" | "cy" | "da" | "de" | "default" | "en" | "eo" | "es" | "et" | "fa" | "fi" | "fr" | "gr" | "he" | "hi" | "hr" | "hu" | "id" | "it" | "ja" | "ko" | "kz" | "lt" | "lv" | "mk" | "mn" | "ms" | "my" | "nl" | "no" | "pa" | "pl" | "pt" | "ro" | "ru" | "si" | "sk" | "sl" | "sq" | "sr" | "sv" | "th" | "tr" | "uk" | "vn" | "zh";
