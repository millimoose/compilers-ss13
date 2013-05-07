#ifndef STATUS_CODES_H
#define STATUS_CODES_H

enum Status {
    StatusSuccess = 0,
    StatusLexerError = 1,
    StatusParserError = 2,
    StatusSemanticError = 3
};

#endif