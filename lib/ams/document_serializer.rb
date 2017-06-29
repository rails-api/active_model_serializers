# frozen_string_literal: true

module AMS
  class DocumentSerializer
    # @abstract
    attr_reader :resource, :resource_serializer, :resource_params, :link_builder

    # @param resource [ActiveRecord::Base] The object to serialize
    # @param resource_serializer [AMS::Serializer] Serializer for the object
    #   Often is "#{controller_name.singularize.classify}Serializer"
    # @param resource_params [ActionController::Parameters] permitted parameters
    # @param link_builder [#url_for] builds a link from controller(resource_type), action, id, and params
    def initialize(resource, resource_serializer, resource_params, link_builder)
      @resource = resource
      @resource_serializer = resource_serializer
      @resource_params = resource_params
      @link_builder = link_builder
    end

    def resource_type
      serializer.type
    end

    def to_json
      JSON.dump(as_json) # calling to_json converts & in links to \u0026, which we don't want or need
    end

    def self.permit_params(params, resource_serializer)
      permitted_params = permitted_action_params(resource_serializer)
      resource_params = params.permit(*permitted_params)
      filter = resource_params[:filter] && resource_params[:filter].any? ? resource_params[:filter].symbolize_keys : nil
      resource_params[:filter] = filter
      resource_params.permit(*permitted_params)
    end
  end

  class ShowDocumentSerializer < DocumentSerializer
    def self.permitted_action_params(resource_serializer)
      [:id, *resource_serializer.show_params]
    end

    def as_json
      {
        "data": data,
        "links": top_level_self_link
      }
    end

    def data
      serializer.as_json
    end

    def serializer
      @_serializer ||= resource_serializer.new(resource, link_builder: link_builder)
    end

    def top_level_self_link
      resource_id = serializer.id
      {
        "self": link_builder.url_for(controller: resource_type, action: :show, id: resource_id)
      }
    end
  end

  class IndexDocumentSerializer < DocumentSerializer
    alias paginated_resource resource

    def self.permitted_action_params(resource_serializer)
      resource_serializer.index_params
    end

    def as_json
      {
        "data": data,
        "meta": top_level_meta,
        "links": top_level_links
      }
    end

    def data
      resource.map do |record|
        serializer(record).as_json
      end
    end

    def serializer(record = nil)
      @_serializer ||= resource_serializer.new(record || resource.first, link_builder: link_builder)
      @_serializer.object = record if record
      @_serializer
    end

    def top_level_meta
      {
        "total_pages": paginated_resource.total_pages,
        "current_page": paginated_resource.current_page
      }
    end

    def top_level_links
      pagination_links
    end

    def pagination_links
      {
        "self": location_url,
        "first": first_page_url,
        "prev": prev_page_url,
        "next": next_page_url,
        "last": last_page_url
      }
    end

    def location_url
      url_for_page
    end

    def first_page_url
      url_for_page(1)
    end

    def prev_page_url
      return nil if paginated_resource.first_page?
      url_for_page(paginated_resource.prev_page)
    end

    def next_page_url
      return nil if paginated_resource.last_page? || paginated_resource.out_of_range?
      url_for_page(paginated_resource.next_page)
    end

    def last_page_url
      url_for_page(paginated_resource.total_pages)
    end

    def url_for_page(number = nil)
      params = resource_params.dup
      params[:page] = paginated_resource.page_params
      params[:page][:number] = number if number
      link_builder.url_for(controller: resource_type, action: :index, params: params)
    end
  end
end
