# frozen_string_literal: true

# Handles changing DbStream attributes
class EditStream
  include ServiceStatus

  def initialize(db_adapter)
    super()
    @db_adapter = db_adapter
  end

  def run(db_stream, attribs)
    # only accept valid attributes
    stream_attribs = attribs.slice(:name, :description,
                                   :hidden, :name_abbrev)
    begin
      stream_attribs[:db_elements_attributes] =
        __parse_element_attribs(attribs[:elements])
    rescue TypeError
      add_error("invalid db_elements_attributes parameter")
      return self
    end
    # assign the new attributes and check if the
    # result is valid (eg elements can't have the same name)
    db_stream.assign_attributes(stream_attribs)
    unless db_stream.valid?
      db_stream.errors
               .full_messages
               .each { |e| add_error(e) }
      return self
    end
    # local model checks out, update the remote NilmDB
    status = @db_adapter.set_stream_metadata(db_stream)
    # if there was an error don't save the model
    if status[:error]
      add_error(status[:msg])
      return self
    end
    # everything went well, save the model
    db_stream.save
    self
  end

  def __parse_element_attribs(attribs)
    if !attribs.nil? && attribs.length>=1
      attribs.map { |element|
        {id: element[:id],
        name: element[:name]}
      }
    else
      []
    end
  end
end