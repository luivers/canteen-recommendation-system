package com.school.canteen.dto.export;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;

/** 评价导出VO，用于Excel导出 */
@Data
public class ReviewExportVO {
    @ExcelProperty("ID")
    @ColumnWidth(10)
    private Long id;

    @ExcelProperty("订单号")
    @ColumnWidth(25)
    private String orderNumber;

    @ExcelProperty("用户名")
    @ColumnWidth(15)
    private String username;

    @ExcelProperty("关联菜品")
    @ColumnWidth(30)
    private String dishNames;

    @ExcelProperty("综合评分")
    @ColumnWidth(10)
    private Double overallRating;

    @ExcelProperty("评价内容")
    @ColumnWidth(40)
    private String comment;

    @ExcelProperty("商家回复")
    @ColumnWidth(40)
    private String reply;

    @ExcelProperty("状态")
    @ColumnWidth(10)
    private String status;

    @ExcelProperty("评价时间")
    @ColumnWidth(20)
    private String createTime;
}
