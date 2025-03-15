module ApplicationHelper
  def youtube_embed_url(video_url)
    return "" if video_url.blank?

    video_id = if video_url.include?("youtu.be")
                 video_url.split("/").last
               elsif video_url.include?("youtube.com/watch")
                 video_url.split("v=").last.split("&").first
               else
                 nil
               end

    video_id ? "https://www.youtube.com/embed/#{video_id}" : ""
  end
end
