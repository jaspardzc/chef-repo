
# Ruby Class for Download Manager 

class DownloadManager

    @@localuri
    @@localmeta
    @@remoteuri
    @@remotemeta
    @@latest_version

    def initialize(_localuri, _remoteuri, _localmeta, _remotemeta)
        # assign instance variables

        @@localuri = _localuri
        @@localmeta = _localmeta
        @@remoteuri = _remoteuri
        @@remotemeta = _remotemeta
        @@latest_version = ""
    end

    def self.getLocalUri()
        return @@localuri
    end

    def self.getLocalMeta()
        return @@localmeta
    end

    def self.getRemoteMeta()
        return @@remotemeta
    end

    def self.getRemoteUri()
        return @@remoteuri
    end

    # a HTML Parser function to find and set the latest verison of wanted artifact
    def self.setLatestVersion(spname)
        # snapshot name
        filename = "/tmp/" + spname

        # war string pattern
        war_pattern = String.new(".war</a>")
        string_pattern_1 = String.new(">")
        string_pattern_2 = String.new("<")

        #create an empty array
        result_array = Array.new
        sorted_result_array = Array.new
    
        #Read file line by line
        input_array = IO.readlines("#{filename}")
        input_array_size = input_array.size

        # iterate the input array and filters out the string contains .war information
        for i in input_array  
            myString = String.new("#{i}")
    
            # push the string into the result_array if the string contains substring '.war</a>'
            if myString.include?war_pattern
                result_array.push(myString)
            end
        end

        # iterate the result array, find out the the string that has larger timestamp appended, 
        # extract the value of the string and assign to a local variable
        for j in result_array
            splitted_array_1  = j.split(pattern=string_pattern_1)
            temp = splitted_array_1[1]
            splitted_array_2 = temp.split(pattern=string_pattern_2)
            temp = splitted_array_2[0]
            sorted_result_array.push(temp)
        end

        # sorting the array by reverse order
        sorted_result_array = sorted_result_array.sort.reverse!

        @@latest_version = sorted_result_array[0]
    end

    def self.getLatestVersion()
        return @@latest_version
    end
end
