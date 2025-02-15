# frozen_string_literal: true

module Spree
  module Api
    class ImagesController < Spree::Api::BaseController
      def index
        @images = scope.images.accessible_by(current_ability, :read)
        respond_with(@images)
      end

      def show
        @image = scope.images.accessible_by(current_ability, :read).find(params[:id])
        respond_with(@image)
      end

      def create
        authorize! :create, Image
        if valid_url? image_params[:attachment]
          @image = scope.images.create(attachment: open(image_params[:attachment]))
        else
          @image = scope.images.create(image_params)
        end
        respond_with(@image, status: 201, default_template: :show)
      end

      def update
        @image = scope.images.accessible_by(current_ability, :update).find(params[:id])
        @image.update(image_params)
        respond_with(@image, default_template: :show)
      end

      def destroy
        @image = scope.images.accessible_by(current_ability, :destroy).find(params[:id])
        @image.destroy
        respond_with(@image, status: 204)
      end

      private

      def image_params
        params.require(:image).permit(permitted_image_attributes)
      end

      def scope
        if params[:product_id]
          Spree::Product.friendly.find(params[:product_id])
        elsif params[:variant_id]
          Spree::Variant.find(params[:variant_id])
        end
      end

      def valid_url?(url)
        uri = URI.parse url
        uri.is_a?(URI::HTTP) && !uri.host.blank?
        rescue URI::InvalidURIError
        false
      end
    end
  end
end
