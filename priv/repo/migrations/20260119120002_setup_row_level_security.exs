defmodule AyomosBlog.Repo.Migrations.SetupRowLevelSecurity do
  use Ecto.Migration

  @moduledoc """
  Sets up Row Level Security (RLS) for Supabase.

  RLS ensures data protection at the database level:
  - Anonymous users can only INSERT into page_views and contact_submissions
  - Only authenticated service role can SELECT/UPDATE/DELETE
  """

  def up do
    # Enable RLS on tables
    execute "ALTER TABLE page_views ENABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE posts ENABLE ROW LEVEL SECURITY"

    # Page Views policies
    # - Anyone can insert (for tracking)
    # - Only service role can read (for admin dashboard)
    execute """
    CREATE POLICY "Allow anonymous inserts to page_views"
    ON page_views
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true)
    """

    execute """
    CREATE POLICY "Allow service role full access to page_views"
    ON page_views
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true)
    """

    # Contact Submissions policies
    # - Anyone can insert (for contact form)
    # - Only service role can read/update (for admin)
    execute """
    CREATE POLICY "Allow anonymous inserts to contact_submissions"
    ON contact_submissions
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true)
    """

    execute """
    CREATE POLICY "Allow service role full access to contact_submissions"
    ON contact_submissions
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true)
    """

    # Posts policies
    # - Anyone can read published posts
    # - Only service role can manage all posts
    execute """
    CREATE POLICY "Allow public to read published posts"
    ON posts
    FOR SELECT
    TO anon, authenticated
    USING (published = true)
    """

    execute """
    CREATE POLICY "Allow service role full access to posts"
    ON posts
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true)
    """
  end

  def down do
    # Drop policies
    execute "DROP POLICY IF EXISTS \"Allow anonymous inserts to page_views\" ON page_views"
    execute "DROP POLICY IF EXISTS \"Allow service role full access to page_views\" ON page_views"
    execute "DROP POLICY IF EXISTS \"Allow anonymous inserts to contact_submissions\" ON contact_submissions"
    execute "DROP POLICY IF EXISTS \"Allow service role full access to contact_submissions\" ON contact_submissions"
    execute "DROP POLICY IF EXISTS \"Allow public to read published posts\" ON posts"
    execute "DROP POLICY IF EXISTS \"Allow service role full access to posts\" ON posts"

    # Disable RLS
    execute "ALTER TABLE page_views DISABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE contact_submissions DISABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE posts DISABLE ROW LEVEL SECURITY"
  end
end
