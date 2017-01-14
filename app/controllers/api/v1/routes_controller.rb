class Api::V1::RoutesController < Api::V1::BaseApiController
  include JsonCollectionPagination
  include DownloadableCsv
  include AllowFiltering

  before_action :set_route, only: [:show]

  def index
    @routes = Route.where('')

    @routes = AllowFiltering.by_onestop_id(@routes, params)
    @routes = AllowFiltering.by_tag_keys_and_values(@routes, params)
    @routes = AllowFiltering.by_identifer_and_identifier_starts_with(@routes, params)
    @routes = AllowFiltering.by_updated_since(@routes, params)

    if params[:imported_from_feed].present?
      @routes = @routes.where_imported_from_feed(Feed.find_by_onestop_id(params[:imported_from_feed]))
    end

    if params[:imported_from_feed_version].present?
      @routes = @routes.where_imported_from_feed_version(FeedVersion.find_by!(sha1: params[:imported_from_feed_version]))
    end

    if params[:serves].present?
      @routes = @routes.where_serves(AllowFiltering.param_as_array(params, :serves))
    end

    if params[:operated_by].present? || params[:operatedBy].present?
      # we previously allowed `operatedBy`, so we'll continue to honor that for the time being
      operator_onestop_id = params[:operated_by] || params[:operatedBy]
      @routes = @routes.operated_by(operator_onestop_id)
    end
    if params[:traverses].present?
      @routes = @routes.traverses(params[:traverses].split(','))
    end
    if params[:vehicle_type].present?
      # some could be integers, some could be strings
      @routes = @routes.where_vehicle_type(AllowFiltering.param_as_array(params, :vehicle_type))
    end
    if params[:bbox].present?
      @routes = @routes.stop_within_bbox(params[:bbox])
    end
    if params[:color].present?
      if ['true', true].include?(params[:color])
        @routes = @routes.where.not(color: nil)
      else
        @routes = @routes.where(color: params[:color].upcase)
      end
    end
    if params[:import_level].present?
      @routes = @routes.where_import_level(AllowFiltering.param_as_array(params, :import_level))
    end

    if params[:wheelchair_accessible].present?
      @routes = @routes.where(wheelchair_accessible: params[:wheelchair_accessible])
    end
    if params[:bikes_allowed].present?
      @routes = @routes.where(bikes_allowed: params[:bikes_allowed])
    end

    @routes = @routes.includes{[
      operator,
      stops,
      route_stop_patterns,
      imported_from_feeds,
      imported_from_feed_versions
    ]}

    respond_to do |format|
      format.json { render paginated_json_collection(@routes).merge({ scope: { exclude_geometry: AllowFiltering.to_boolean(params[:exclude_geometry]) } }) }
      format.geojson { render paginated_geojson_collection(@routes) }
      format.csv { return_downloadable_csv(@routes, 'routes') }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @route, scope: { exclude_geometry: AllowFiltering.to_boolean(params[:exclude_geometry]) } }
      format.geojson { render json: @route, serializer: GeoJSONSerializer }
    end
  end

  private

  def query_params
    params.slice(
      :identifier,
      :identifier_starts_with,
      :operated_by,
      :operatedBy,
      :color,
      :vehicle_type,
      :bbox,
      :onestop_id,
      :tag_key,
      :tag_value,
      :import_level,
      :imported_from_feed,
      :imported_from_feed_version,
      :exclude_geometry
    )
  end

  def set_route
    @route = Route.find_by_onestop_id!(params[:id])
  end
end
