module Page exposing (Page(..))

import Page.HomePage
import Page.StoryPage
import Page.UserPage


type Page
    = NotFound
    | Home Page.HomePage.Model
    | Story Page.StoryPage.Model
    | User Page.UserPage.Model
