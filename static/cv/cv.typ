#import "@preview/fontawesome:0.5.0": *
#import "@preview/scienceicons:0.1.0": *


#show link: set text(fill: rgb("#09847A"))

// Load all data files
#let education_data = toml("../../data/education.toml")
#let experience_data = toml("../../data/experience.toml")
#let publications_data = toml("../../data/publications.toml")
#let conferences_data = toml("../../data/conferences.toml")
#let social_data = toml("../../data/social.toml")
#let awards_data = toml("../../data/awards.toml")
#let coursework_data = toml("../../data/coursework.toml")
#let funding_data = toml("../../data/funding.toml")
#let software_data = toml("../../data/software.toml")
#let site_url = toml("../../config.toml").base_url

// Set document properties
#set document(
  title: "Jonathan Skaza - Curriculum Vitae",
  author: "Jonathan Skaza",
)

// Page setup with modern margins
#set page(
  margin: (x: 0.9in, y: 1.0in),
  numbering: "1",
  number-align: center,
  footer: [
    #set text(size: 8pt, fill: gray)
    #grid(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      [],
      [Last updated: #datetime.today().display("[month repr:long] [day], [year]")],
      context [#counter(page).display()]
    )
  ],
)

// Modern typography
#set text(
  font: ("Avenir Next", "Helvetica Neue", "Arial"),
  size: 11pt,
  lang: "en",
)

// Paragraph spacing
#set par(justify: true, leading: 0.6em)

// Custom colors
#let accent_color = rgb("#2c3e50")
#let light_accent = rgb("#34495e")

// Template functions
#let sectionBlock(title, content) = [
  #grid(
    columns: (4fr, 13.8fr),
    smallcaps(
      text(font: ("Avenir Next", "Helvetica Neue", "Optima"), size: 14.5pt, fill: accent_color, weight: "bold", title),
    ),
    content,
  )
  #v(20pt)
]

#let eduHeading(institution: [], degree: [], advisor: []) = [
  #strong(institution) \ #emph(degree) \ #advisor
]


#let experienceHeading(title: [], company: [], location: [], time: [], url: none) = [
  #grid(
    columns: (60%, 40%),
    row-gutter: 8pt,
    align: (left, right),
    [#strong(title)],
    time,
    if company != [] [#company] + if url != none and url != "" [ #h(4pt) #link(url)[#fa-icon("university")]],
    if location != [] [#location],
  )
]

#let award(title: [], time: []) = [
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    [- #title], time,
  )
]

#let awardEntry(name: [], year: none, year_range: none, description: none) = [
  #let time_text = if year != none {
    str(year)
  } else if year_range != none {
    year_range
  } else {
    ""
  }
  
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    [#name#if description != none [ (#description)]], 
    [#time_text],
  )
]

// Custom functions for CV
#let pubEntry(authors: [], year: [], title: [], journal: none, volume: none, url: none, github_repo: none) = [
  #let author_text = authors.join(", ")
  #let year_text = "(" + str(year) + ")"

  #grid(
    columns: 1fr,
    align: left,
    [#author_text #year_text. "#title."#if journal != none [ #emph(journal)]#if volume != none [, #volume].#if url != none [ #link(url)[ #h(2pt) #h(2pt) #fa-icon("file-text")]]#if github_repo != none [ #link(github_repo)[ #h(2pt) #h(2pt) #fa-icon("github")]]]
  )
  #v(8pt)
]

#let confEntry(title: [], authors: [], venue: [], location: [], year: [], links: ()) = [
  #let author_text = authors.join(", ")
  #let year_text = "(" + str(year) + ")"

  #grid(
    columns: 1fr,
    align: left,
    [#author_text #year_text. "#title."#if venue != [] [ #emph(venue)]#if location != [] [, #location].#if links.len() > 0 [ #h(2pt) #for link_item in links [
      #let icon_symbol = if link_item.name == "Poster" {
        fa-icon("image")
      } else if link_item.name == "Slides" {
        fa-icon("display")
      } else {
        text(fill: accent_color)[↗]
      }
      #link(site_url + link_item.url)[#h(2pt) #icon_symbol]
    ]]]
  )
  #v(8pt)
]

#let fundingEntry(name: [], year: [], url: none) = [
  #grid(
    columns: (3fr, 1fr),
    align: (left, right),
    [#name#if url != none and url != "" [ #link(url)[#h(4pt) #fa-icon("award")]]], 
    [#year],
  )
]

#let softwareEntry(name: [], description: [], url: none) = [
  #fa-icon("code") #raw(name): #description#if url != none [ #link(url)[#h(4pt) #fa-icon("github")]]
  #v(4pt)
]

// Helper functions
#let format_date_range(start, end: none) = {
  if end != none {
    str(start) + "–" + str(end)
  } else {
    str(start) + "–Present"
  }
}

#let format_contact() = {
  let contacts = ()
  for item in social_data.social {
    if item.name == "Email" {
      contacts.push(link(item.url)[#fa-icon("envelope") #item.url.replace("mailto:", "")])
    } else if item.name == "GitHub" {
      contacts.push(link(item.url)[#fa-icon("github") GitHub])
    } else if item.name == "LinkedIn" {
      contacts.push(link(item.url)[#fa-icon("linkedin") LinkedIn])
    } else if item.name == "Google Scholar" {
      contacts.push(link(item.url)[#fa-icon("graduation-cap") Google Scholar])
    } else if item.name == "X" {
      contacts.push(link(item.url)[#fa-icon("x-twitter") X])
    } else if item.name == "ORCID" {
      contacts.push(link(item.url)[#orcid-icon(color:  rgb("#09847A")) ORCID])
    }
  }
      // Add website link
    contacts.push(link(site_url)[#fa-icon("globe") #site_url.replace("https://", "")])
  contacts.join("   ")
}

// Header
#align(center)[
  #text(size: 32pt, weight: "bold", fill: accent_color)[Jonathan Skaza] \
  #line(length: 100%, stroke: 1pt)
  #text(size: 10pt)[#format_contact()]
  #line(length: 100%, stroke: 1pt)
]

#v(25pt)

// Education Section
#sectionBlock("Education")[
  #for edu in education_data.education [
    #eduHeading(
      institution: edu.institution,
      degree: edu.degree,
      advisor: if "advisor" in edu and edu.advisor != "" [Advisor:  #edu.advisor] else [],
    )
    #v(12pt)
  ]
]

// Experience Section
#sectionBlock("Experience")[
  #for exp in experience_data.experience [
    #experienceHeading(
      title: exp.title,
      company: exp.company,
      location: exp.location,
      time: format_date_range(exp.start_date, end: exp.at("end_date", default: none)),
      url: exp.at("url", default: none),
    )
    #v(8pt)
    #text(size: 10pt)[#exp.description]
    #v(15pt)
  ]
]

// Publications Section
#sectionBlock("Publications")[
  #let pubs_sorted = publications_data.publication.sorted(key: pub => -pub.pub_year)

  #for pub in pubs_sorted [
    #text(size: 9pt, fill: light_accent)[#pubEntry(
      authors: pub.author,
      year: pub.pub_year,
      title: pub.title,
      journal: pub.at("journal", default: none),
      volume: pub.at("volume", default: none),
      url: pub.at("url", default: none),
      github_repo: pub.at("github_repo", default: none),
    )
  ]
]
]

// Conference Presentations Section
#sectionBlock([Conferences \ 
 &  \ 
Talks])[
  #let confs_sorted = conferences_data.conference.sorted(key: conf => -conf.date)

  #for conf in confs_sorted [
    #text(size: 9pt, fill: light_accent)[#confEntry(
      title: conf.title,
      authors: conf.author,
      venue: conf.venue,
      location: conf.location,
      year: conf.date,
      links: conf.at("links", default: ()),
    )
  ]
  ]
]

// Software Section
#sectionBlock("Software")[
  #for software in software_data.software [
    #softwareEntry(
      name: software.name,
      description: software.description,
      url: software.at("url", default: none),
    )
  ]
]

// Funding and Support Section
#sectionBlock([Funding \ 
 &  \ 
Support])[
  #let funding_sorted = funding_data.funding.sorted(key: funding => {
    // Extract the end year from year range for sorting
    let year_str = funding.year
    if year_str.contains("-") {
      let parts = year_str.split("-")
      if parts.len() > 1 {
        -int(parts.at(1))
      } else {
        -int(parts.at(0))
      }
    } else {
      -int(year_str)
    }
  })

  #for funding in funding_sorted [
    #fundingEntry(
      name: funding.name,
      year: funding.year,
      url: funding.at("url", default: none),
    )
  ]
]

// Awards Section
#sectionBlock("Awards")[
  #let awards_sorted = awards_data.awards.sorted(key: award => {
    if "year" in award {
      -award.year
    } else if "year_range" in award {
      // Extract the end year from year_range for sorting
      let parts = award.year_range.split("-")
      if parts.len() > 1 {
        -int(parts.at(1))
      } else {
        -int(parts.at(0))
      }
    } else {
      0
    }
  })

  #for award in awards_sorted [
    #awardEntry(
      name: award.name,
      year: award.at("year", default: none),
      year_range: award.at("year_range", default: none),
      description: award.at("description", default: none),
    )
  ]
]

// Coursework Section
#sectionBlock("Select Coursework")[
  #let courses = coursework_data.courses
  #let course_list = courses.join(", ")
  #text(size: 10pt)[#course_list]
]
