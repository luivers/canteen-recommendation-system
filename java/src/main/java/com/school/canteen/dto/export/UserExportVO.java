package com.school.canteen.dto.export;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;

import java.math.BigDecimal;

/** 用户导出VO，用于Excel导出 */
@Data
public class UserExportVO {
    @ExcelProperty("ID")
    @ColumnWidth(10)
    private Long id;

    @ExcelProperty("用户名")
    @ColumnWidth(15)
    private String username;

    @ExcelProperty("昵称")
    @ColumnWidth(15)
    private String nickname;

    @ExcelProperty("手机号")
    @ColumnWidth(15)
    private String phoneNumber;

    @ExcelProperty("邮箱")
    @ColumnWidth(25)
    private String email;

    @ExcelProperty("角色")
    @ColumnWidth(15)
    private String role;

    @ExcelProperty("余额")
    @ColumnWidth(10)
    private BigDecimal balance;

    @ExcelProperty("积分")
    @ColumnWidth(10)
    private Integer points;

    @ExcelProperty("状态")
    @ColumnWidth(10)
    private String status;

    @ExcelProperty("注册时间")
    @ColumnWidth(20)
    private String createTime;
}
