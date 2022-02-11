local Package = {}

Package.Info = {
    Name = "Message",
    Description = "Creates a new message and send to a specific user",
    Author = "7kayoh",
    Type = "Command",
}

Package.SpecialConfig = {
    Aliases = { "msg", "m", "dm", "pm" },
    Category = "Messaging",
    Arguments = {
        { Id = "user", Name = "User", Description = "Username/UserId", Type = "user" },
        { Id = "title", Name = "Title", Description = "Message title", Type = "string"} ,
        { Id = "content", Name = "Content", Description = "Message content", Type = "longString" },
        { Id = "isImportant", Name = "Mark message as important", Description = "Notify the user right away no matter their status", Type = "boolean" },
        { Id = "reason", Name = "Reason", Description = "Why this message is important", Type = "string" , If = "$isImportant:true" },
        { Id = "random-thing", Name = "Random", Description = "Blah blah.", Type = "List", FetchFrom = Package.onDataFetch }
    },
}

function Package.onCall(commandContext, globalContext)

end

function Package.onDataFetch(argumentId)
    if argumentId == "random-thing" then
        return {
            "A",
            "B",
            "Funny, you are!",
            "Just kidding, your humour sucks"
        }
    end

    return {}
end

return Package