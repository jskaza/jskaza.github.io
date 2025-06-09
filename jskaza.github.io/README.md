# Academic CV Theme for Zola

A clean, professional academic website theme for Zola, inspired by the Hugo Blox Academic CV template. Perfect for researchers, academics, and professionals who want to showcase their work.

## Features

✨ **Modern Design**: Clean, professional layout with excellent typography
🌓 **Dark Mode**: Automatic dark/light mode with user preference storage
📱 **Responsive**: Looks great on desktop, tablet, and mobile devices
🎨 **Customizable**: Easy to customize colors, fonts, and layout
📄 **Publication Management**: Dedicated section for research papers with citation support
🎤 **Talks & Presentations**: Showcase your conference talks and presentations
📰 **News & Updates**: Share your latest achievements and news
💼 **Experience Timeline**: Display your professional and academic experience
🚀 **Fast Loading**: Optimized for speed and performance
🔍 **SEO Optimized**: Built-in SEO best practices

## Quick Start

1. **Install Zola** (if you haven't already):
   ```bash
   # On macOS with Homebrew
   brew install zola
   
   # On Ubuntu/Debian
   snap install --edge zola
   
   # Or download from https://github.com/getzola/zola/releases
   ```

2. **Customize Your Information**:
   Edit `config.toml` to update your personal information:
   ```toml
   [extra]
   name = "Your Name"
   role = "Your Title"
   organization = "Your Institution"
   email = "your.email@example.com"
   bio = "Your bio description"
   ```

3. **Add Your Photo**:
   Place a square photo named `avatar.jpg` in the `static/` directory

4. **Add Your CV**:
   Place your CV as `cv.pdf` in the `static/` directory

5. **Preview Your Site**:
   ```bash
   zola serve
   ```
   Visit `http://127.0.0.1:1111` to see your site

## Customization

### Personal Information

Edit the `[extra]` section in `config.toml`:

```toml
[extra]
name = "Your Name"
role = "Professor of Computer Science"
organization = "University of Example"
location = "City, Country"
email = "your.email@university.edu"
bio = "Brief description about yourself and your research interests."
```

### Social Links

Add or modify social links in `config.toml`:

```toml
[[extra.social]]
name = "Email"
url = "mailto:your.email@example.com"
icon = "fas fa-envelope"

[[extra.social]]
name = "Google Scholar"
url = "https://scholar.google.com/citations?user=YOUR-ID"
icon = "ai ai-google-scholar"
```

### Education

Update your education in `config.toml`:

```toml
[[extra.education]]
degree = "PhD in Computer Science"
institution = "MIT"
year = "2020"
```

### Colors and Theme

The theme uses CSS custom properties for easy customization. Edit `sass/style.scss`:

```scss
:root {
  --primary-color: #2962ff;  // Change main accent color
  --secondary-color: #757575;
  // ... other variables
}
```

## Content Management

### Publications

Add publications in `content/publications/`:

```markdown
+++
title = "Your Paper Title"
date = 2023-07-01
description = "Brief description of the paper"

[extra]
authors = ["You", "Co-Author"]
venue = "Conference Name"
links = [
    { name = "PDF", url = "/papers/your-paper.pdf" },
    { name = "Code", url = "https://github.com/you/repo" }
]
citation = """@inproceedings{...}"""
+++

## Abstract
Your paper abstract here...
```

### Talks

Add talks in `content/talks/`:

```markdown
+++
title = "Your Talk Title"
date = 2023-06-01
description = "Talk description"

[extra]
venue = "Conference Name"
location = "City, Country"
links = [
    { name = "Slides", url = "/talks/slides.pdf" },
    { name = "Video", url = "https://youtube.com/..." }
]
+++

Talk content here...
```

### News

Add news items in `content/news/`:

```markdown
+++
title = "News Title"
date = 2023-05-01
+++

News content here...
```

### Projects

Add projects in `content/projects/`:

```markdown
+++
title = "Project Name"
date = 2023-04-01
description = "Project description"

[extra]
links = [
    { name = "GitHub", url = "https://github.com/you/project" },
    { name = "Demo", url = "https://demo.example.com" }
]
+++

Project details here...
```

## File Structure

```
your-site/
├── config.toml          # Site configuration
├── content/             # Content files
│   ├── _index.md       # Homepage content
│   ├── publications/   # Research papers
│   ├── talks/          # Presentations
│   ├── news/           # News and updates
│   ├── experience/     # Work experience
│   └── projects/       # Project portfolio
├── templates/          # HTML templates
│   ├── base.html       # Base template
│   ├── index.html      # Homepage template
│   ├── section.html    # Section listing template
│   └── page.html       # Individual page template
├── sass/               # Stylesheets
│   └── style.scss      # Main stylesheet
└── static/             # Static assets
    ├── avatar.jpg      # Your photo
    ├── cv.pdf          # Your CV
    ├── papers/         # Paper PDFs
    └── talks/          # Talk slides
```

## Navigation Menu

The navigation menu is configured in `config.toml`:

```toml
[[extra.menu]]
name = "About"
url = "/"
weight = 1

[[extra.menu]]
name = "Publications"
url = "/publications/"
weight = 2
```

## Dark Mode

Dark mode is enabled by default. Users can toggle between light and dark modes using the moon icon in the navigation. The preference is saved in localStorage.

To disable dark mode, set in `config.toml`:
```toml
[extra]
enable_dark_mode = false
```

## SEO and Performance

The theme includes:
- Semantic HTML structure
- Meta tags for social media sharing
- Optimized images and fonts
- Minimal CSS and JavaScript
- Fast loading times

## Deployment

### GitHub Pages

1. Push your site to a GitHub repository
2. Enable GitHub Pages in repository settings
3. Set source to GitHub Actions
4. The site will build and deploy automatically

### Netlify

1. Connect your GitHub repository to Netlify
2. Set build command: `zola build`
3. Set publish directory: `public`
4. Deploy!

### Vercel

1. Connect your repository to Vercel
2. Vercel will automatically detect it's a Zola site
3. Deploy!

## Customization Examples

### Changing the Primary Color

Edit `sass/style.scss`:
```scss
:root {
  --primary-color: #1976d2; // Material Blue
}
```

### Adding a New Section

1. Create directory: `content/teaching/`
2. Add `_index.md` with frontmatter
3. Add to navigation menu in `config.toml`

### Custom Fonts

Add to `templates/base.html`:
```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
```

Update `sass/style.scss`:
```scss
:root {
  --font-family: 'Inter', sans-serif;
}
```

## Troubleshooting

**Site not building?**
- Check that all required frontmatter is present
- Ensure TOML syntax is correct in `config.toml`
- Run `zola check` to validate content

**Styles not loading?**
- Make sure `compile_sass = true` in `config.toml`
- Check that `sass/style.scss` exists

**Images not showing?**
- Verify files are in the `static/` directory
- Check file paths and extensions

## Contributing

Feel free to submit issues and pull requests to improve this theme!

## License

This theme is open source and available under the MIT License. 