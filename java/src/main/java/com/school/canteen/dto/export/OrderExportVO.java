package com.school.canteen.dto.export;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;

import java.math.BigDecimal;

/** 订单导出VO，用于Excel导出 */
@Data
public class OrderExportVO {
    @ExcelProperty("订单号")
    @ColumnWidth(25)
    private String orderNumber;

    @ExcelProperty("用户ID")
    @ColumnWidth(10)
    private Long userId;

    @ExcelProperty("总金额")
    @ColumnWidth(10)
    private BigDecimal totalAmount;

    @ExcelProperty("状态")
    @ColumnWidth(15)
    private String status;

    @ExcelProperty("取餐码")
    @ColumnWidth(10)
    private String pickupCode;

    @ExcelProperty("下单时间")
    @ColumnWidth(20)
    private String createTime;

    @ExcelProperty("完成时间")
    @ColumnWidth(20)
    private String completionTime;

    @ExcelProperty("菜品详情")
    @ColumnWidth(40)
    private String items;

    @ExcelProperty("食堂")
    @ColumnWidth(15)
    private String canteenName;

    @ExcelProperty("窗口")
    @ColumnWidth(15)
    private String windowName;
}
