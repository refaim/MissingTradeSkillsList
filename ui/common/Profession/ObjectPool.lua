---@shape MTSL_PoolObject
---@field Deinitialise fun(): void

---@class MTSL_ObjectPool<T: MTSL_PoolObject>
---@field __pool T[]
MTSL_ObjectPool = {}

---@param template T
function MTSL_ObjectPool:Construct(template)
    self.__template = template
    self.__pool = {}
end

---@return T
function MTSL_ObjectPool:Get()
    if getn(self.__pool) == 0 then
        tinsert(self.__pool, MTSL_TOOLS:CopyObject(self.__template))
    end
    return tremove(self.__pool)
end

---@param object T
function MTSL_ObjectPool:Release(object)
    object:Deinitialise()
    tinsert(self.__pool, object)
end
