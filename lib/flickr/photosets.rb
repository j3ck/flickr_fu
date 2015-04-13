class Flickr::Photosets < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  # Get a list of photosets
  #
  # *calls*: {flickr.photosets.getList}[https://www.flickr.com/services/api/flickr.photosets.getList.html]
  #
  # ==== Options
  # * +:user_id+ (optional) - The NSID of the user to get a photoset list for.
  #   If none is specified, the calling user is assumed.
  # * +:page+ (Optional) - The page of results to get. Currently, if this is not provided,
  #   all sets are returned, but this behaviour may change in future
  # * +:per_page+ (optional) - The number of sets to get per page.
  #   If paging is enabled+, the maximum number of sets per page is 500.
  # * +:primary_photo_extras+ (Optional) - A comma-delimited list of extra information to fetch for the primary photo.
  #
  # ==== Returns
  # an array of Flickr::Photosets::Photoset (s)
  def get_list(options={})
    rsp = @flickr.send_request('flickr.photosets.getList', options)
    collect_photosets(rsp)
  end

  # Create a new Photoset
  #
  # *calls*: {flickr.photosets.create}[https://www.flickr.com/services/api/flickr.photosets.create.html]
  #
  # ==== Parameters
  # * +title+ (required)[String] A title for the photoset.
  # * +primary_photo_id+ (required)[String] The id of the photo to represent this set.
  # ==== Options
  # * +:description+ - A description of the photoset. May contain limited html.
  #
  # ==== Returns
  # * A Flickr::Photosets::Photoset instance
  #
  def create(title, primary_photo_id, options={})
    options.merge!({:title => title, :primary_photo_id => primary_photo_id})
    @flickr.send_request('flickr.photosets.create', options)
  end

  protected
    def collect_photosets(rsp)
      photosets = []
      return photosets unless rsp
      if rsp.photosets.photoset
        rsp.photosets.photoset.each do |photoset|
          attributes = create_attributes(photoset)
          photosets << Photoset.new(@flickr, attributes)
        end
      end
      return photosets
    end

    def create_attributes(photoset)
      # comment by : smeevil
      #
      # for some reason it was needed to call to_s on photoset.title and photoset.description
      # without this it will not set the value correctly
      {
        :id => photoset[:id],
        :num_photos => photoset[:photos],
        :title => photoset.title.to_s,
        :description => photoset.description.to_s
       }
    end

end
