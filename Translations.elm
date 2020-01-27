module Translations exposing (Translations, parse)

import Json.Decode exposing (Decoder, Error, Value, map, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Translations_headline =
    { notFound : String
    , donate : String
    , personalLink : String
    , status : String
    , collect : String
    , profile : String
    }


decodeTranslations_headline : Decoder Translations_headline
decodeTranslations_headline =
    succeed Translations_headline
        |> required "notFound" string
        |> required "donate" string
        |> required "personalLink" string
        |> required "status" string
        |> required "collect" string
        |> required "profile" string


type alias Translations_misc =
    { comingSoon : String
    , homeLinkTitle : String
    }


decodeTranslations_misc : Decoder Translations_misc
decodeTranslations_misc =
    succeed Translations_misc
        |> required "comingSoon" string
        |> required "homeLinkTitle" string


type alias Translations_userCard =
    { shareProfile : String
    , visitProfile : String
    }


decodeTranslations_userCard : Decoder Translations_userCard
decodeTranslations_userCard =
    succeed Translations_userCard
        |> required "shareProfile" string
        |> required "visitProfile" string


type alias Translations_donate_error =
    { title : String
    , description : String
    , reloadButtonLabel : String
    , helpText : String
    , supportLinkTitle : String
    }


decodeTranslations_donate_error : Decoder Translations_donate_error
decodeTranslations_donate_error =
    succeed Translations_donate_error
        |> required "title" string
        |> required "description" string
        |> required "reloadButtonLabel" string
        |> required "helpText" string
        |> required "supportLinkTitle" string


type alias Translations_donate_withoutUser =
    { title : String
    , hint : String
    }


decodeTranslations_donate_withoutUser : Decoder Translations_donate_withoutUser
decodeTranslations_donate_withoutUser =
    succeed Translations_donate_withoutUser
        |> required "title" string
        |> required "hint" string


type alias Translations_donate_form =
    { donateeGroupInfoLinkTitle : String
    , selectPriceLabel : String
    , selectCurrencyLabel : String
    , emailFieldPlaceholder : String
    , stripeCheckoutErrorMessage : { message : String } -> String
    , nextButtonLabel : String
    , submitButtonLabel : String
    , donateeGroupFieldLabel : String
    , messageFieldLabel : String
    , messageFieldPlaceholder : String
    , priceLabel : String
    }


decodeTranslations_donate_form : Decoder Translations_donate_form
decodeTranslations_donate_form =
    let
        substitute_stripeCheckoutErrorMessage content args =
            content
                |> String.replace "{{message}}" args.message
    in
    succeed Translations_donate_form
        |> required "donateeGroupInfoLinkTitle" string
        |> required "selectPriceLabel" string
        |> required "selectCurrencyLabel" string
        |> required "emailFieldPlaceholder" string
        |> required "stripeCheckoutErrorMessage" (map substitute_stripeCheckoutErrorMessage string)
        |> required "nextButtonLabel" string
        |> required "submitButtonLabel" string
        |> required "donateeGroupFieldLabel" string
        |> required "messageFieldLabel" string
        |> required "messageFieldPlaceholder" string
        |> required "priceLabel" string


type alias Translations_donate =
    { error : Translations_donate_error
    , withoutUser : Translations_donate_withoutUser
    , form : Translations_donate_form
    }


decodeTranslations_donate : Decoder Translations_donate
decodeTranslations_donate =
    succeed Translations_donate
        |> required "error" decodeTranslations_donate_error
        |> required "withoutUser" decodeTranslations_donate_withoutUser
        |> required "form" decodeTranslations_donate_form


type alias Translations_donateeGroup =
    { cleanOcean : String
    , plantTrees : String
    , protectWildlife : String
    }


decodeTranslations_donateeGroup : Decoder Translations_donateeGroup
decodeTranslations_donateeGroup =
    succeed Translations_donateeGroup
        |> required "cleanOcean" string
        |> required "plantTrees" string
        |> required "protectWildlife" string


type alias Translations_copyLinkToClipboard =
    { inputLabel : String
    , copyButtonTitle : String
    , copySuccessMessage : String
    , shareButtonTitle : String
    }


decodeTranslations_copyLinkToClipboard : Decoder Translations_copyLinkToClipboard
decodeTranslations_copyLinkToClipboard =
    succeed Translations_copyLinkToClipboard
        |> required "inputLabel" string
        |> required "copyButtonTitle" string
        |> required "copySuccessMessage" string
        |> required "shareButtonTitle" string


type alias Translations_status_notPaid =
    { headline : String
    , message : { currency : String, price : String, donateeGroup : String } -> String
    }


decodeTranslations_status_notPaid : Decoder Translations_status_notPaid
decodeTranslations_status_notPaid =
    let
        substitute_message content args =
            content
                |> String.replace "{{currency}}" args.currency
                |> String.replace "{{price}}" args.price
                |> String.replace "{{donateeGroup}}" args.donateeGroup
    in
    succeed Translations_status_notPaid
        |> required "headline" string
        |> required "message" (map substitute_message string)


type alias Translations_status_paid =
    { preHeadline : String
    , headline : { currency : String, price : String, donateeGroup : String } -> String
    , message : String
    }


decodeTranslations_status_paid : Decoder Translations_status_paid
decodeTranslations_status_paid =
    let
        substitute_headline content args =
            content
                |> String.replace "{{currency}}" args.currency
                |> String.replace "{{price}}" args.price
                |> String.replace "{{donateeGroup}}" args.donateeGroup
    in
    succeed Translations_status_paid
        |> required "preHeadline" string
        |> required "headline" (map substitute_headline string)
        |> required "message" string


type alias Translations_status_paidAndNotified =
    { message : { user : String } -> String
    }


decodeTranslations_status_paidAndNotified : Decoder Translations_status_paidAndNotified
decodeTranslations_status_paidAndNotified =
    let
        substitute_message content args =
            content
                |> String.replace "{{user}}" args.user
    in
    succeed Translations_status_paidAndNotified
        |> required "message" (map substitute_message string)


type alias Translations_status_paidAndCollected =
    { message : { user : String, date : String } -> String
    }


decodeTranslations_status_paidAndCollected : Decoder Translations_status_paidAndCollected
decodeTranslations_status_paidAndCollected =
    let
        substitute_message content args =
            content
                |> String.replace "{{user}}" args.user
                |> String.replace "{{date}}" args.date
    in
    succeed Translations_status_paidAndCollected
        |> required "message" (map substitute_message string)


type alias Translations_status_donationReceipt =
    { requested : String
    , notRequested : String
    , errorWithRetry : String
    , error : String
    }


decodeTranslations_status_donationReceipt : Decoder Translations_status_donationReceipt
decodeTranslations_status_donationReceipt =
    succeed Translations_status_donationReceipt
        |> required "requested" string
        |> required "notRequested" string
        |> required "errorWithRetry" string
        |> required "error" string


type alias Translations_status =
    { notPaid : Translations_status_notPaid
    , paid : Translations_status_paid
    , paidAndNotified : Translations_status_paidAndNotified
    , paidAndCollected : Translations_status_paidAndCollected
    , donationReceipt : Translations_status_donationReceipt
    }


decodeTranslations_status : Decoder Translations_status
decodeTranslations_status =
    succeed Translations_status
        |> required "notPaid" decodeTranslations_status_notPaid
        |> required "paid" decodeTranslations_status_paid
        |> required "paidAndNotified" decodeTranslations_status_paidAndNotified
        |> required "paidAndCollected" decodeTranslations_status_paidAndCollected
        |> required "donationReceipt" decodeTranslations_status_donationReceipt


type alias Translations_collect_incomplete =
    { headline : String
    , message : String
    }


decodeTranslations_collect_incomplete : Decoder Translations_collect_incomplete
decodeTranslations_collect_incomplete =
    succeed Translations_collect_incomplete
        |> required "headline" string
        |> required "message" string


type alias Translations_collect_success =
    { headline : String
    , message : { email : String } -> String
    }


decodeTranslations_collect_success : Decoder Translations_collect_success
decodeTranslations_collect_success =
    let
        substitute_message content args =
            content
                |> String.replace "{{email}}" args.email
    in
    succeed Translations_collect_success
        |> required "headline" string
        |> required "message" (map substitute_message string)


type alias Translations_collect_form =
    { headline : String
    , emailFieldPlaceholder : String
    , submitButtonLabel : String
    }


decodeTranslations_collect_form : Decoder Translations_collect_form
decodeTranslations_collect_form =
    succeed Translations_collect_form
        |> required "headline" string
        |> required "emailFieldPlaceholder" string
        |> required "submitButtonLabel" string


type alias Translations_collect_explainWhy =
    { headline : String
    , message : String
    }


decodeTranslations_collect_explainWhy : Decoder Translations_collect_explainWhy
decodeTranslations_collect_explainWhy =
    succeed Translations_collect_explainWhy
        |> required "headline" string
        |> required "message" string


type alias Translations_collect =
    { from : { user : String } -> String
    , defaultMessage : String
    , donationLine : { donateeGroup : String } -> String
    , incomplete : Translations_collect_incomplete
    , success : Translations_collect_success
    , form : Translations_collect_form
    , explainWhy : Translations_collect_explainWhy
    }


decodeTranslations_collect : Decoder Translations_collect
decodeTranslations_collect =
    let
        substitute_from content args =
            content
                |> String.replace "{{user}}" args.user

        substitute_donationLine content args =
            content
                |> String.replace "{{donateeGroup}}" args.donateeGroup
    in
    succeed Translations_collect
        |> required "from" (map substitute_from string)
        |> required "defaultMessage" string
        |> required "donationLine" (map substitute_donationLine string)
        |> required "incomplete" decodeTranslations_collect_incomplete
        |> required "success" decodeTranslations_collect_success
        |> required "form" decodeTranslations_collect_form
        |> required "explainWhy" decodeTranslations_collect_explainWhy


type alias Translations_personalLink_stored =
    { shareHeadline : String
    , profileLinkTitle : String
    , foreignSlugMessage : String
    , resetButtonTitle : String
    }


decodeTranslations_personalLink_stored : Decoder Translations_personalLink_stored
decodeTranslations_personalLink_stored =
    succeed Translations_personalLink_stored
        |> required "shareHeadline" string
        |> required "profileLinkTitle" string
        |> required "foreignSlugMessage" string
        |> required "resetButtonTitle" string


type alias Translations_personalLink_generated =
    { successHeadline : String
    , shareHeadline : String
    , shareMessage : String
    }


decodeTranslations_personalLink_generated : Decoder Translations_personalLink_generated
decodeTranslations_personalLink_generated =
    succeed Translations_personalLink_generated
        |> required "successHeadline" string
        |> required "shareHeadline" string
        |> required "shareMessage" string


type alias Translations_personalLink_emailSent =
    { headline : String
    , message : { email : String } -> String
    }


decodeTranslations_personalLink_emailSent : Decoder Translations_personalLink_emailSent
decodeTranslations_personalLink_emailSent =
    let
        substitute_message content args =
            content
                |> String.replace "{{email}}" args.email
    in
    succeed Translations_personalLink_emailSent
        |> required "headline" string
        |> required "message" (map substitute_message string)


type alias Translations_personalLink_form_nickname =
    { label : String
    , placeholder : String
    , cannotBeBlank : String
    , tooShort : { count : String } -> String
    }


decodeTranslations_personalLink_form_nickname : Decoder Translations_personalLink_form_nickname
decodeTranslations_personalLink_form_nickname =
    let
        substitute_tooShort content args =
            content
                |> String.replace "{{count}}" args.count
    in
    succeed Translations_personalLink_form_nickname
        |> required "label" string
        |> required "placeholder" string
        |> required "cannotBeBlank" string
        |> required "tooShort" (map substitute_tooShort string)


type alias Translations_personalLink_form_slug =
    { label : String
    , placeholder : String
    , cannotBeBlank : String
    , tooShort : { count : String } -> String
    , invalidCharacters : String
    , alreadyTaken : String
    , hint : String
    }


decodeTranslations_personalLink_form_slug : Decoder Translations_personalLink_form_slug
decodeTranslations_personalLink_form_slug =
    let
        substitute_tooShort content args =
            content
                |> String.replace "{{count}}" args.count
    in
    succeed Translations_personalLink_form_slug
        |> required "label" string
        |> required "placeholder" string
        |> required "cannotBeBlank" string
        |> required "tooShort" (map substitute_tooShort string)
        |> required "invalidCharacters" string
        |> required "alreadyTaken" string
        |> required "hint" string


type alias Translations_personalLink_form_profileInfo =
    { name : String
    , slug : String
    , helpAvatar : String
    , helpName : String
    , helpLink : String
    }


decodeTranslations_personalLink_form_profileInfo : Decoder Translations_personalLink_form_profileInfo
decodeTranslations_personalLink_form_profileInfo =
    succeed Translations_personalLink_form_profileInfo
        |> required "name" string
        |> required "slug" string
        |> required "helpAvatar" string
        |> required "helpName" string
        |> required "helpLink" string


type alias Translations_personalLink_form =
    { headline : String
    , emailFieldPlaceholder : String
    , submitButtonLabel : String
    , nickname : Translations_personalLink_form_nickname
    , slug : Translations_personalLink_form_slug
    , profileInfo : Translations_personalLink_form_profileInfo
    }


decodeTranslations_personalLink_form : Decoder Translations_personalLink_form
decodeTranslations_personalLink_form =
    succeed Translations_personalLink_form
        |> required "headline" string
        |> required "emailFieldPlaceholder" string
        |> required "submitButtonLabel" string
        |> required "nickname" decodeTranslations_personalLink_form_nickname
        |> required "slug" decodeTranslations_personalLink_form_slug
        |> required "profileInfo" decodeTranslations_personalLink_form_profileInfo


type alias Translations_personalLink =
    { stored : Translations_personalLink_stored
    , generated : Translations_personalLink_generated
    , emailSent : Translations_personalLink_emailSent
    , form : Translations_personalLink_form
    }


decodeTranslations_personalLink : Decoder Translations_personalLink
decodeTranslations_personalLink =
    succeed Translations_personalLink
        |> required "stored" decodeTranslations_personalLink_stored
        |> required "generated" decodeTranslations_personalLink_generated
        |> required "emailSent" decodeTranslations_personalLink_emailSent
        |> required "form" decodeTranslations_personalLink_form


type alias Translations_profile_thankuCount =
    { headline : String
    , collected : String
    , sent : String
    }


decodeTranslations_profile_thankuCount : Decoder Translations_profile_thankuCount
decodeTranslations_profile_thankuCount =
    succeed Translations_profile_thankuCount
        |> required "headline" string
        |> required "collected" string
        |> required "sent" string


type alias Translations_profile_donationStats =
    { headline : String
    , empty : String
    }


decodeTranslations_profile_donationStats : Decoder Translations_profile_donationStats
decodeTranslations_profile_donationStats =
    succeed Translations_profile_donationStats
        |> required "headline" string
        |> required "empty" string


type alias Translations_profile =
    { donateButtonLabel : String
    , thankuCount : Translations_profile_thankuCount
    , donationStats : Translations_profile_donationStats
    }


decodeTranslations_profile : Decoder Translations_profile
decodeTranslations_profile =
    succeed Translations_profile
        |> required "donateButtonLabel" string
        |> required "thankuCount" decodeTranslations_profile_thankuCount
        |> required "donationStats" decodeTranslations_profile_donationStats


type alias Translations_shareProfileLink =
    { headline : String
    , description : String
    , createProfileLinkTitle : String
    }


decodeTranslations_shareProfileLink : Decoder Translations_shareProfileLink
decodeTranslations_shareProfileLink =
    succeed Translations_shareProfileLink
        |> required "headline" string
        |> required "description" string
        |> required "createProfileLinkTitle" string


type alias Translations_emailField =
    { cannotBeBlank : String
    , notAnEmail : String
    , label : String
    }


decodeTranslations_emailField : Decoder Translations_emailField
decodeTranslations_emailField =
    succeed Translations_emailField
        |> required "cannotBeBlank" string
        |> required "notAnEmail" string
        |> required "label" string


type alias Translations_httpError =
    { title : String
    , description : String
    , retryButtonLabel : String
    , homeButtonLabel : String
    , retryMessage : String
    , unexpectedMessage : String
    }


decodeTranslations_httpError : Decoder Translations_httpError
decodeTranslations_httpError =
    succeed Translations_httpError
        |> required "title" string
        |> required "description" string
        |> required "retryButtonLabel" string
        |> required "homeButtonLabel" string
        |> required "retryMessage" string
        |> required "unexpectedMessage" string


type alias Translations =
    { lang : String
    , headline : Translations_headline
    , misc : Translations_misc
    , userCard : Translations_userCard
    , donate : Translations_donate
    , donateeGroup : Translations_donateeGroup
    , copyLinkToClipboard : Translations_copyLinkToClipboard
    , status : Translations_status
    , collect : Translations_collect
    , personalLink : Translations_personalLink
    , profile : Translations_profile
    , newsletterButtonLabel : String
    , shareProfileLink : Translations_shareProfileLink
    , emailField : Translations_emailField
    , httpError : Translations_httpError
    }


decodeTranslations : Decoder Translations
decodeTranslations =
    succeed Translations
        |> required "lang" string
        |> required "headline" decodeTranslations_headline
        |> required "misc" decodeTranslations_misc
        |> required "userCard" decodeTranslations_userCard
        |> required "donate" decodeTranslations_donate
        |> required "donateeGroup" decodeTranslations_donateeGroup
        |> required "copyLinkToClipboard" decodeTranslations_copyLinkToClipboard
        |> required "status" decodeTranslations_status
        |> required "collect" decodeTranslations_collect
        |> required "personalLink" decodeTranslations_personalLink
        |> required "profile" decodeTranslations_profile
        |> required "newsletterButtonLabel" string
        |> required "shareProfileLink" decodeTranslations_shareProfileLink
        |> required "emailField" decodeTranslations_emailField
        |> required "httpError" decodeTranslations_httpError


parse : Value -> Result Error Translations
parse =
    Json.Decode.decodeValue decodeTranslations