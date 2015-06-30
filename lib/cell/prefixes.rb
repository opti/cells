module Cell::Prefixes
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  def _prefixes
    self.class.prefixes
  end

  def _assets_prefixes
    self.class.assets_prefixes
  end

  # You're free to override those methods in case you want to alter our view inheritance.
  module ClassMethods
    def prefixes
      @prefixes ||= _prefixes
    end

    def assets_prefixes
      @assets_prefixes ||= _assets_prefixes
    end

  private
    def _prefixes
      return [] if abstract?
      _local_prefixes + superclass.prefixes
    end

    def _local_prefixes
      view_paths.collect { |path| "#{path}/#{controller_path}" }
    end

    # Instructs Cells to inherit views from a parent cell without having to inherit class code.
    def inherit_views(parent)
      define_method :_prefixes do
        super() + parent.prefixes
      end
    end

    def _assets_prefixes
      return [] if abstract?
      _local_assets_prefixes + superclass.assets_prefixes
    end

    def _local_assets_prefixes
      _local_paths_collection.inject([]) do |memo, paths|
        memo.push(paths.join("/"))
      end
    end

    def _local_paths_collection
      attrs = [[controller_path], assets_paths].reject(&:empty?)
      view_paths.product(*attrs)
    end
  end
end
