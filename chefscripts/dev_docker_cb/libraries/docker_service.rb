## Docker Service Class
# 
# find container by name, throw exception if container does not exist
# 
# get container running status by container name
# 
# start the container by name
# 
# stop the container by name
# 
# remove the container by name
#
## ./Docker Service Class

# manage dependencies
require 'docker'
require 'json'

class DockerService
    
    # local data variables
    @container
    @container_status

    # default constructor
    def initialize()

    end

    # find container by name
    def findContainerByName(name)
        begin
            container = Docker::Container.get(name)
            if container
                puts "Container with name: #{name} is found."
                return container
            end
        rescue
            puts "Container with name: #{name} does not exist."
        end
    end

    # get container running status by name
    def getContainerStatus(container)
        begin 
           container_status = container.json["State"]["Running"]
           return container_status
        rescue
            puts "Container in not valid."
        end
    end

    # start the container by name
    def startContainerByName(name)
        begin
            @container = findContainerByName(name)
            @container_status = getContainerStatus(@container)
            if false == @container_status
                @container.start
                puts "Successfully started the container with name: #{name}."
            else
                puts "Container with name: #{name} is already running."
            end
        rescue
            puts "Fail to start the container with name: #{name}."
        end

    end

    # stop the container by name
    def stopContainerByName(name)
        begin
            @container = findContainerByName(name)
            @container_status = getContainerStatus(@container)
            if true == @container_status
                @container.stop
                puts "Successfully stopped the container with name: #{name}."
            else 
                puts "Container with name: #{name} is already stopped."
            end
        rescue
            puts "Fail to stop the container with name: #{name}."
        end
    end

    # remove the container by name
    def removeContainerByName(name)
        begin
            @container = findContainerByName(name)
            @container_status = getContainerStatus(@container)
            if true == @container_status
                @container.stop
            end
            @container.delete
        rescue
            puts "Fail to remove the container with name: #{name}."
        end
    end
end

