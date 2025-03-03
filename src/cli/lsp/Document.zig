const Document = @This();

const std = @import("std");
const assert = std.debug.assert;
const superhtml = @import("superhtml");

const log = std.log.scoped(.lsp_document);

language: superhtml.Language,
src: []const u8,
html: superhtml.html.Ast,
super: ?superhtml.Ast = null,

pub fn deinit(doc: *Document, gpa: std.mem.Allocator) void {
    doc.html.deinit(gpa);
    if (doc.super) |s| s.deinit(gpa);
}

pub fn init(
    gpa: std.mem.Allocator,
    src: []const u8,
    language: superhtml.Language,
) error{OutOfMemory}!Document {
    var doc: Document = .{
        .src = src,
        .language = language,
        .html = try superhtml.html.Ast.init(gpa, src, language),
    };
    errdefer doc.html.deinit(gpa);

    if (language == .superhtml and doc.html.errors.len == 0) {
        const super_ast = try superhtml.Ast.init(gpa, doc.html, src);
        errdefer super_ast.deinit(gpa);
        doc.super = super_ast;
    }

    return doc;
}

pub fn reparse(doc: *Document, gpa: std.mem.Allocator) !void {
    doc.deinit(gpa);
    doc.html = try superhtml.html.Ast.init(gpa, doc.src, doc.language);
    errdefer doc.html.deinit(gpa);

    if (doc.language == .superhtml and doc.html.errors.len == 0) {
        doc.super = try superhtml.Ast.init(gpa, doc.html, doc.src);
    } else {
        doc.super = null;
    }

    return;
}
