module RailsNewsfeed
  class Connection
    # inserts
    def self.insert(tbl, schema, vals, to_cql = false)
      cql = "INSERT INTO #{tbl} (#{vals.keys.join(',')}) VALUES (#{cass_vals(schema, vals)})"
      return cql if to_cql
      exec_cql(cql)
      true
    end

    # updates
    def self.update(tbl, schema, conditions, vals, to_cql = false)
      # unsets primary keys
      conditions.keys.each { |k| vals.delete(k) }
      val_s = exported_col_val(schema, vals).join(',')
      cql = "UPDATE #{tbl} SET #{val_s} WHERE #{exported_col_val(schema, conditions).join(' AND ')}"
      return cql if to_cql
      exec_cql(cql)
      true
    end

    # deletes
    def self.delete(tbl, schema, conditions, to_cql = false)
      cql = "DELETE FROM #{tbl} WHERE #{exported_col_val(schema, conditions).join(' AND ')}"
      return cql if to_cql
      exec_cql(cql)
      true
    end

    # selects
    def self.select(tbl, schema = {}, columns = '*', conditions = {}, options = {})
      cql = 'SELECT '
      cql += columns unless columns.is_a?(Array)
      cql += columns.join(',') if columns.is_a?(Array)
      cql += " FROM #{tbl}"
      cql += " WHERE #{exported_col_val(schema, conditions).join(' AND ')}" unless conditions.empty?
      if options[:filtering]
        cql += ' ALLOW FILTERING'
        options.delete(:filtering)
      end
      exec_cql(cql, options)
    end

    # gets cassandra connection
    def self.connection
      return @connection if @connection
      config ||= YAML.load_file('config/cassandra.yml')[Rails.env]
      @connection = Cassandra.cluster(config || {}).connect(config['keyspace'])
    end

    # executes cql
    def self.exec_cql(cql, options = {})
      connection.execute(cql, options)
    end

    # executes batch
    def self.batch_cqls(cqls, options = {})
      return true if cqls.empty?
      batch = connection.batch do |b|
        cqls.each do |cql|
          b.add(cql)
        end
      end
      exec_cql(batch, options)
    end

    # exports a value to cassandra value
    def self.cass_val(val, type)
      return 'null' if val.nil?
      case type
      when :ascii, :text, :varchar, :timestamp
        return "'#{val.to_s.gsub("'", "''")}'"
      else
        val
      end
    end

    # exports values to cassandra values
    def self.cass_vals(schema, vals)
      cass_vals = []
      vals.each do |col, val|
        cass_vals.push(cass_val(val, schema[col]))
      end
      cass_vals.join(',')
    end

    # exports column value pair
    def self.exported_col_val(schema, col_val_pair)
      a = []
      col_val_pair.each do |col, val|
        a.push("#{col}=#{cass_val(val, schema[col])}")
      end
      a
    end
  end
end
