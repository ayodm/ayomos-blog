# AYOMOS.COM - Personal Blog

A brutalist, minimalist, futuristic blog built with Elixir and Phoenix Framework. 
Focus: Data Analytics in Enterprise Risk Management.

## 🚀 Quick Start

### Development

```bash
# Install dependencies
mix setup

# Start the server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) from your browser.

### Admin Panel

Access the admin panel at [`localhost:4000/admin/posts`](http://localhost:4000/admin/posts) to:
- Create new blog posts
- Edit existing posts
- Manage publication status

## 📁 Project Structure

```
ayomos_blog/
├── lib/
│   ├── ayomos_blog/        # Business logic
│   │   └── blog/           # Blog context (posts)
│   └── ayomos_blog_web/    # Web layer
│       ├── controllers/    # Page & Post controllers
│       └── components/     # Layouts & components
├── priv/
│   ├── repo/              # Database migrations & seeds
│   └── static/            # Static assets
└── assets/
    └── css/               # Tailwind CSS with brutalist theme
```

## 🎨 Theme Features

- **Brutalist Design**: Sharp edges, high contrast, no rounded corners
- **Minimalist Layout**: Focus on content, clean typography
- **Futuristic Elements**: ASCII art, terminal aesthetics, grid patterns
- **Dark Mode Default**: Easy on the eyes, with light mode toggle
- **Responsive**: Mobile-first design

## 🛠 Tech Stack

- **Elixir** - Functional programming language
- **Phoenix Framework** - Web framework
- **SQLite3** - Database (via Ecto)
- **Tailwind CSS v4** - Styling with daisyUI
- **HeEx Templates** - Phoenix templating

## 🌐 Deployment to ayomos.com

### Option 1: Fly.io (Recommended)

```bash
# Install flyctl
brew install flyctl

# Launch your app
fly launch

# Deploy
fly deploy
```

### Option 2: Docker

```bash
# Build the release
mix phx.gen.release --docker

# Build Docker image
docker build -t ayomos-blog .

# Run container
docker run -p 4000:4000 ayomos-blog
```

### Environment Variables (Production)

```bash
SECRET_KEY_BASE=<generate with `mix phx.gen.secret`>
DATABASE_URL=sqlite3:///data/ayomos_blog.db
PHX_HOST=ayomos.com
PORT=4000
```

## 📝 Creating Blog Posts

1. Go to `/admin/posts`
2. Click "New Post"
3. Fill in:
   - **Title**: Post title
   - **Slug**: URL-friendly identifier (e.g., `my-first-post`)
   - **Excerpt**: Brief summary for listings
   - **Body**: Full content (supports Markdown-like formatting)
   - **Published**: Check to make visible
   - **Published at**: Publication date/time

## 🔗 Routes

| Path | Description |
|------|-------------|
| `/` | Home page |
| `/about` | About page |
| `/blog` | Blog listing |
| `/blog/:slug` | Single post |
| `/admin/posts` | Admin dashboard |
| `/admin/posts/new` | Create post |
| `/admin/posts/:id/edit` | Edit post |

## 📞 Contact

- **Website**: [ayomos.com](https://ayomos.com)
- **LinkedIn**: [linkedin.com/in/ayomosanya](https://linkedin.com/in/ayomosanya)
- **Email**: ayo@ayomos.com

## 📄 License

© 2026 Ayo Mosanya. All rights reserved.
