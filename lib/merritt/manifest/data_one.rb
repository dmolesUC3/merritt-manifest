module Merritt
  class Manifest
    # A specialization of {Manifest} for DataONE.
    class DataONE < Manifest

      # A marker interface for file-like objects
      module File
        # @return [String] the name of this file
        attr_reader :name

        # @return [String, MIME::Type] the MIME type of this file
        attr_reader :type
      end

      # Creates a new {Manifest::DataONE}
      # @param files [Array<Manifest::DataONE::File>] an array of data files to be converted to entries.
      #   (Note that these not be actual {Manifest::DataONE::File} objects so long as they respond to
      #   `#name` and `#type`)
      def initialize(files:)
        super(
          conformance: 'dataonem_0.1',
          profile: 'http://uc3.cdlib.org/registry/ingest/manifest/mrt-dataone-manifest',
          prefixes: {
            dom: 'http://uc3.cdlib.org/ontology/dataonem',
            mrt: 'http://uc3.cdlib.org/ontology/mom'
          },
          fields: [METADATA_FILE, METADATA_FORMAT, DATA_FILE, MIME_TYPE],
          entries: to_entries(files)
        )
      end

      private

      METADATA_FILE = 'dom:scienceMetadataFile'.freeze
      METADATA_FORMAT = 'dom:scienceMetadataFormat'.freeze
      DATA_FILE = 'dom:scienceDataFile'.freeze
      MIME_TYPE = 'mrt:mimeType'.freeze

      METADATA_FILES = {
        'mrt-datacite.xml' => 'http://datacite.org/schema/kernel-3.1',
        'mrt-oaidc.xml' => 'http://dublincore.org/schemas/xmls/qdc/2008/02/11/qualifieddc.xsd'
      }.freeze

      def to_entries(files)
        rows = files.product(METADATA_FILES.to_a).map(&:flatten)
        rows.map do |file, md_name, md_url|
          {
            METADATA_FILE => md_name,
            METADATA_FORMAT => md_url,
            DATA_FILE => file.name,
            MIME_TYPE => file.type
          }
        end
      end
    end
  end
end
