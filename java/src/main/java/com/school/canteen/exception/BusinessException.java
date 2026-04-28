package com.school.canteen.exception;

import org.springframework.http.HttpStatus;

/** 业务异常类，携带错误码和HTTP状态码 */
public class BusinessException extends RuntimeException {
    private final String code;
    private final HttpStatus httpStatus;

    public BusinessException(String code, String message) {
        this(code, HttpStatus.BAD_REQUEST, message);
    }

    public BusinessException(String code, HttpStatus httpStatus, String message) {
        super(message);
        this.code = code;
        this.httpStatus = httpStatus;
    }

    public String getCode() {
        return code;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }
}
