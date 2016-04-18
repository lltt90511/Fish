
local dbpath = CCFileUtils:sharedFileUtils():getWritablePath().."userdata.db"
dbHandlerFile = nil
if platform == "Windows" then
    dbpath = "tmp/userdata"
    for i= 1,20 do
        local delete = false
        local file,err = io.open("tmp/"..i..".dbHandler","w")
        if file then
            file:close()
            xpcall(function ()
                local res= os.remove("tmp/"..i..".dbHandler")
                print("removeFile ".."tmp/"..i..".dbHandler",res)
                if res == true then
                    delete = true
                end
            end)
        else
            delete = true
        end
        if delete  then
            dbHandlerFile = io.open("tmp/"..i..".dbHandler","a")
            print (i)
            --assert(false,type(dbHandlerFile))
            local b = i-1
            if b == 0 then
                dbpath = dbpath..".db"
            else
                dbpath = dbpath..b..".db"
            end
            break
        end
    end

end
print (dbpath)
function DBQuery(db,sql)
    local result = {}
    local execCallBack = function (udata,cols,values,names) 
        local res = {}
        for i=1,cols do 
            res[names[i]] = values[i]
        end
        table.insert( result, res  )
        return 0
    end
    local r = db:exec(sql,execCallBack,cols)
    assert (r == 0,"sqlite exec error\nsql:"..sql.."\nerrMsg: " ..db:errmsg())
    return result
end

DBType = {
    FILE_DB = 1,
    MEM_DB = 2,
}
function createDBObject(type,file)
    local db = {}
    db.file = file
    db.type = type
    db.open = function ()
        if type == DBType.FILE_DB then
            db.db = sqlite3.open(file)
        elseif type == DBType.MEM_DB then
            db.db = sqlite3.open_memory()
        else
            assert(false,"error db type")
        end
    end
    db.query = function (sql)
        return DBQuery(db.db,sql)
    end
    db.exec = function (sql)
        DBQuery(db.db,sql)
    end
    db.wrap = function (sql)
        db.db:close()
        if db.type == DBType.FILE_DB then
            os.remove(db.file)
        end
        db.open()
    end
    db.open()
    return db
end

fDB = createDBObject(DBType.FILE_DB,dbpath)
mDB = createDBObject(DBType.MEM_DB)
local createTable=[=[
    CREATE TABLE if not exists TEST_TABLE(id,name,str);
    insert into TEST_TABLE values(1,"xxxx","xxxxxxxx");
    insert into TEST_TABLE values(2,"xxxx","xxxxxxxx");
    CREATE TABLE if not exists UserChar(id integer primary key autoincrement, myCharId, otherCharId, msg, charId, charName, targetCharId, targetCharName, time, hadRead);
    CREATE TABLE if not exists Setting(name,val);
]=]
fDB.exec(createTable)
local testSql = [=[select * from TEST_TABLE]=]
printTable(fDB.query(testSql))
local clean = [=[DROP  table TEST_TABLE;]=]
fDB.exec(clean)
--fDB.wrap()
