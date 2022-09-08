require 'helper'

describe "DalliDeleteMatched" do
  describe "Cache Keys" do
    it "checks for cache keys" do
      memcached(19121, '', {}) do |dc|
        assert_equal ActiveSupport::Cache::MemCacheStore.new('localhost:19121').send(:get_cache_keys), []
      end
    end

    it "inserts a cache key and returns it as a key" do
      memcached(19122, '', {}) do |dc|
        dc.flush

        store = ActiveSupport::Cache::MemCacheStore.new('localhost:19122')
        store.instance_variable_get(:@data).with do |connection|
          store.send :write_entry, "test", "content", { :connection => connection }
        end
        assert_equal store.send(:get_cache_keys), ["test"]
      end
    end

    it "delete a key should delete key and cache keys" do
      memcached(19122, '', {}) do |dc|
        dc.flush

        store = ActiveSupport::Cache::MemCacheStore.new('localhost:19122')
        store.instance_variable_get(:@data).with do |connection|
          store.send :write_entry, "test", "content", { :connection => connection }
          store.send :delete_entry, "test", { :connection => connection }
        end

        assert_equal store.send(:get_cache_keys), []
      end
    end

    it "delete a matched keys " do
      memcached(19122, '', {}) do |dc|
        dc.flush

        store = ActiveSupport::Cache::MemCacheStore.new('localhost:19122')
        store.instance_variable_get(:@data).with do |connection|
          store.send :write_entry, "key1", "content1", { :connection => connection }
          store.send :write_entry, "key2", "content1", { :connection => connection }
          store.send :write_entry, "k2", "content1", { :connection => connection }
          store.send :delete_matched, /key.*/, { :connection => connection }
        end

        assert_equal store.send(:get_cache_keys), ['k2']
      end
    end
  end
end
