pub const Page_t: type = struct {
    // ...

    pub fn New() !Page_t {
        // Allocate Physical Page
    }
};

pub const PageTable_t: type = struct {
    // ...

    pub fn New() !PageTable_t {
        // Initialize Page Table
    }

    pub fn Add(self: *PageTable_t, page: Page_t) void {
        // Add Page to the Page Table
    }

    pub fn Delete(self: *PageTable_t) void {
        // Deinitialize Page Table
        // Deallocate All Allocated pages
    }
};
