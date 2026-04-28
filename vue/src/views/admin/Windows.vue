<template>
  <div class="windows-container">
    <div class="page-header">
      <h1 class="page-title">窗口管理</h1>
      <p class="page-subtitle">管理食堂窗口信息</p>
    </div>

    <!-- 操作按钮区域 -->
    <div class="action-buttons">
      <el-button type="primary" @click="showAddWindowDialog">
        <el-icon><Plus /></el-icon> 添加窗口
      </el-button>
      <el-button type="success" @click="syncWindowsFromDishes">
        <el-icon><RefreshLeft /></el-icon> 从菜品数据同步
      </el-button>
    </div>

    <!-- 食堂和窗口列表 -->
    <el-card class="windows-card">
      <template #header>
        <div class="card-header">
          <span>窗口列表</span>
        </div>
      </template>

      <div class="canteens-windows">
        <!-- 食堂列表 -->
        <div class="canteen-list">
          <el-tree
            :data="canteenTree"
            :props="treeProps"
            :default-expand-all="true"
            class="canteen-tree"
            @node-click="handleCanteenSelect"
          >
            <template #default="{ node, data }">
              <div class="tree-node">
                <el-icon v-if="data.children && data.children.length > 0"
                  ><Shop
                /></el-icon>
                <el-icon v-else><Shop /></el-icon>
                <span class="node-label">{{ node.label }}</span>
                <span v-if="data.windowCount" class="window-count"
                  >({{ data.windowCount }}个窗口)</span
                >
              </div>
            </template>
          </el-tree>
        </div>

        <!-- 窗口详情 -->
        <div class="window-details">
          <div v-if="!selectedCanteen && !selectedWindow" class="no-selection">
            <el-empty description="请选择一个食堂查看窗口列表" />
          </div>
          <div v-else-if="selectedWindow" class="window-detail">
            <div class="selected-window-info">
              <h3>{{ selectedWindow.name }} - 窗口详情</h3>
              <el-button
                type="primary"
                size="small"
                @click="showEditWindowDialog(selectedWindow)"
              >
                <el-icon><Edit /></el-icon> 编辑
              </el-button>
              <el-button
                type="success"
                size="small"
                style="margin-left: 10px"
                @click="showAssignDishesDialog(selectedWindow)"
              >
                <el-icon><Food /></el-icon> 分配菜品
              </el-button>
              <el-button
                type="danger"
                size="small"
                style="margin-left: 10px"
                @click="deleteWindow(selectedWindow.id)"
              >
                <el-icon><Delete /></el-icon> 删除
              </el-button>
            </div>

            <el-card class="window-detail-card">
              <el-descriptions :column="2" border>
                <el-descriptions-item label="窗口ID">{{
                  selectedWindow.id
                }}</el-descriptions-item>
                <el-descriptions-item label="窗口名称">{{
                  selectedWindow.name
                }}</el-descriptions-item>
                <el-descriptions-item label="位置">{{
                  selectedWindow.location
                }}</el-descriptions-item>
                <el-descriptions-item label="营业时间">{{
                  selectedWindow.operatingHours || "未设置"
                }}</el-descriptions-item>
                <el-descriptions-item label="负责人">{{
                  selectedWindow.managerName || "未设置"
                }}</el-descriptions-item>
                <el-descriptions-item label="状态">
                  <el-tag
                    :type="
                      selectedWindow.status === 'OPEN'
                        ? 'success'
                        : selectedWindow.status === 'CLOSED'
                          ? 'info'
                          : 'danger'
                    "
                    size="small"
                  >
                    {{
                      selectedWindow.status === "OPEN"
                        ? "营业中"
                        : selectedWindow.status === "CLOSED"
                          ? "已关闭"
                          : "维护中"
                    }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="所属食堂">{{
                  selectedWindow.canteenName
                }}</el-descriptions-item>
                <el-descriptions-item label="创建时间">
                  {{
                    new Date(selectedWindow.createTime).toLocaleString("zh-CN")
                  }}
                </el-descriptions-item>
                <el-descriptions-item label="更新时间" span="2">
                  {{
                    new Date(selectedWindow.updateTime).toLocaleString("zh-CN")
                  }}
                </el-descriptions-item>
              </el-descriptions>
            </el-card>
          </div>
          <div v-else>
            <div class="selected-canteen-info">
              <h3>{{ selectedCanteen.name }} - 窗口列表</h3>
              <el-button
                type="primary"
                size="small"
                @click="showAddWindowDialog(selectedCanteen)"
              >
                <el-icon><Plus /></el-icon> 添加窗口
              </el-button>
            </div>

            <el-table
              :data="filteredWindows"
              style="width: 100%"
              stripe
              :default-sort="{ prop: 'id', order: 'asc' }"
              @row-click="handleWindowRowClick"
            >
              <el-table-column prop="id" label="窗口ID" width="80" />
              <el-table-column prop="name" label="窗口名称" min-width="150" />
              <el-table-column prop="location" label="位置" min-width="150" />
              <el-table-column
                prop="operatingHours"
                label="营业时间"
                width="140"
              />
              <el-table-column prop="managerName" label="负责人" width="100" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag
                    :type="
                      row.status === 'OPEN'
                        ? 'success'
                        : row.status === 'CLOSED'
                          ? 'info'
                          : 'danger'
                    "
                    size="small"
                  >
                    {{
                      row.status === "OPEN"
                        ? "营业中"
                        : row.status === "CLOSED"
                          ? "已关闭"
                          : "维护中"
                    }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="创建日期" width="120">
                <template #default="{ row }">
                  {{ row.createTime ? row.createTime.substring(0, 10) : '' }}
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 添加/编辑窗口对话框 -->
    <el-dialog
      v-model="windowDialogVisible"
      :title="isEditing ? '编辑窗口' : '添加窗口'"
      width="500px"
    >
      <el-form
        ref="windowFormRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="食堂ID" prop="canteenId">
          <el-input
            v-model="form.canteenId"
            type="number"
            placeholder="请输入食堂ID"
          />
        </el-form-item>

        <el-form-item label="食堂名称" prop="canteenName">
          <el-input v-model="form.canteenName" placeholder="请输入食堂名称" />
        </el-form-item>

        <el-form-item label="窗口名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入窗口名称" />
        </el-form-item>

        <el-form-item label="位置" prop="location">
          <el-input v-model="form.location" placeholder="请输入窗口位置" />
        </el-form-item>

        <el-form-item label="营业时间" prop="operatingHours">
          <el-input
            v-model="form.operatingHours"
            placeholder="请输入营业时间，如：08:00-18:00"
          />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择窗口状态">
            <el-option label="营业中" value="OPEN" />
            <el-option label="已关闭" value="CLOSED" />
            <el-option label="维护中" value="MAINTENANCE" />
          </el-select>
        </el-form-item>

        <el-form-item label="负责人ID" prop="managerId">
          <el-input
            v-model="form.managerId"
            type="number"
            placeholder="请输入负责人ID"
          />
        </el-form-item>

        <el-form-item label="负责人姓名" prop="managerName">
          <el-input v-model="form.managerName" placeholder="请输入负责人姓名" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="windowDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveWindow">保存</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 菜品分配对话框 -->
    <el-dialog
      v-model="assignDishesDialogVisible"
      :title="`分配菜品 - ${selectedWindow?.name || ''}`"
      width="800px"
    >
      <!-- 搜索和筛选区域 -->
      <div
        class="search-section"
        style="
          margin-bottom: 20px;
          display: flex;
          align-items: center;
          gap: 20px;
        "
      >
        <!-- 菜品名称搜索 -->
        <div>
          <el-input
            v-model="searchKeyword"
            placeholder="搜索菜品名称"
            clearable
            prefix-icon="Search"
            style="width: 300px"
          />
          <el-button
            type="primary"
            style="margin-left: 10px; margin-top: 10px"
            @click="handleSearch"
          >
            搜索
          </el-button>
        </div>

        <!-- 菜系分类筛选 -->
        <div>
          <el-select
            v-model="selectedCategory"
            placeholder="按菜系分类筛选"
            clearable
            style="width: 200px"
          >
            <el-option
              v-for="category in categories"
              :key="category"
              :label="category"
              :value="category"
            />
          </el-select>
          <el-button
            type="success"
            style="margin-left: 10px"
            @click="handleCategoryFilter"
          >
            筛选
          </el-button>
        </div>

        <!-- 重置筛选 -->
        <el-button style="margin-left: 10px" @click="resetFilters">
          重置
        </el-button>
      </div>

      <!-- 菜品列表 -->
      <el-table
        v-loading="loadingDishes"
        :data="filteredDishes"
        style="width: 100%"
        height="400"
        @selection-change="handleDishSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="菜品ID" width="80" />
        <el-table-column prop="name" label="菜品名称" width="200" />
        <el-table-column label="菜系分类" width="150">
          <template #default="scope">
            {{
              scope.row.windowName
                ? scope.row.windowName.replace("窗口", "")
                : "未分类"
            }}
          </template>
        </el-table-column>
        <el-table-column prop="price" label="价格" width="100">
          <template #default="scope"> ¥{{ scope.row.price }} </template>
        </el-table-column>
        <el-table-column label="当前窗口" width="200">
          <template #default="scope">
            {{ scope.row.canteenName ? scope.row.canteenName : '' }}{{ scope.row.windowName || '未分配' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag
              :type="scope.row.status === 'AVAILABLE' ? 'success' : 'danger'"
            >
              {{ scope.row.status === "AVAILABLE" ? "在售" : "下架" }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="assignDishesDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="assignDishes"
            >分配选中菜品</el-button
          >
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Plus,
  RefreshLeft,
  Shop,
  Edit,
  Delete,
  Food,
} from "@element-plus/icons-vue";
import { windowApi } from "@/api/window";
import { dishApi } from "@/api/dish";

// 响应式数据
const canteens = ref([]);
const windows = ref([]);
const canteenTree = ref([]);
const selectedCanteen = ref(null);
const windowDialogVisible = ref(false);
const assignDishesDialogVisible = ref(false);
const isEditing = ref(false);
const windowFormRef = ref(null);
const selectedWindow = ref(null);
const dishes = ref([]);
const filteredDishes = ref([]);
const searchKeyword = ref("");
const loadingDishes = ref(false);
const selectedDishes = ref([]);
const categories = ref([]);
const selectedCategory = ref("");
const originalDishes = ref([]);

// 表单数据
const form = reactive({
  id: null,
  canteenId: null,
  canteenName: "",
  name: "",
  location: "",
  operatingHours: "",
  status: "OPEN",
  managerId: null,
  managerName: "",
});

// 表单验证规则
const rules = {
  canteenId: [
    { required: true, message: "请输入食堂ID", trigger: "blur" },
    // { type: "number", message: "食堂ID必须为数字", trigger: "blur" }, // 移除此验证，因为 el-input type="number" 也会返回字符串
  ],
  canteenName: [{ required: true, message: "请输入食堂名称", trigger: "blur" }],
  name: [
    { required: true, message: "请输入窗口名称", trigger: "blur" },
    {
      min: 2,
      max: 50,
      message: "窗口名称长度在 2 到 50 个字符",
      trigger: "blur",
    },
  ],
  location: [{ required: true, message: "请输入窗口位置", trigger: "blur" }],
  status: [{ required: true, message: "请选择窗口状态", trigger: "change" }],
};

// 树状图配置
const treeProps = {
  label: "name",
  children: "children",
};

// 计算属性：根据选择的食堂过滤窗口
const filteredWindows = computed(() => {
  if (!selectedCanteen.value) return [];
  return windows.value.filter(
    (window) => window.canteenId === selectedCanteen.value.id,
  );
});

// 加载所有食堂
const loadCanteens = async () => {
  try {
    const response = await windowApi.getCanteens();
    canteens.value = response.data || [];

    // 加载所有窗口
    await loadWindows();
  } catch (error) {
    ElMessage.error(
      "加载食堂失败：" + (error.response?.data?.message || error.message),
    );
  }
};

// 加载所有窗口
const loadWindows = async () => {
  try {
    const response = await windowApi.getAllWindows();
    windows.value = response.data || [];

    // 构建食堂和窗口的树状结构
    buildCanteenTree();
  } catch (error) {
    ElMessage.error(
      "加载窗口失败：" + (error.response?.data?.message || error.message),
    );
  }
};

// 构建食堂树状结构
const buildCanteenTree = () => {
  const tree = [];

  // 遍历食堂
  canteens.value.forEach((canteen) => {
    const canteenNode = {
      id: canteen.id,
      name: canteen.name,
      windowCount: canteen.windowCount,
      children: [],
    };

    // 查找该食堂下的所有窗口
    const canteenWindows = windows.value.filter(
      (window) => window.canteenId === canteen.id,
    );
    canteenWindows.forEach((window) => {
      canteenNode.children.push({
        id: window.id,
        name: window.name,
        isWindow: true,
      });
    });

    tree.push(canteenNode);
  });

  canteenTree.value = tree;
};

// 处理食堂选择
const handleCanteenSelect = (data) => {
  if (data.isWindow) {
    // 选择的是窗口，查找并显示窗口详情
    selectedWindow.value = windows.value.find(
      (window) => window.id === data.id,
    );
    return;
  }
  // 选择的是食堂，显示该食堂的窗口列表
  selectedCanteen.value = data;
  selectedWindow.value = null;
};

// 处理窗口行点击
const handleWindowRowClick = (row) => {
  selectedWindow.value = row;
};

// 显示添加窗口对话框
const showAddWindowDialog = (canteen = null) => {
  isEditing.value = false;
  form.id = null;
  form.canteenId = canteen?.id || null;
  form.canteenName = canteen?.name || "";
  form.name = "";
  form.location = "";
  form.operatingHours = "";
  form.status = "OPEN";
  form.managerId = null;
  form.managerName = "";
  windowDialogVisible.value = true;
};

// 显示编辑窗口对话框
const showEditWindowDialog = (window) => {
  isEditing.value = true;
  form.id = window.id;
  form.canteenId = window.canteenId;
  form.canteenName = window.canteenName;
  form.name = window.name;
  form.location = window.location;
  form.operatingHours = window.operatingHours;
  form.status = window.status;
  form.managerId = window.managerId;
  form.managerName = window.managerName;
  windowDialogVisible.value = true;
};

// 保存窗口
const saveWindow = async () => {
  if (!windowFormRef.value) return;

  try {
    await windowFormRef.value.validate();

    if (isEditing.value) {
      // 更新窗口
      await windowApi.updateWindow(form.id, form);
      ElMessage.success("窗口更新成功");
    } else {
      // 添加窗口
      await windowApi.createWindow(form);
      ElMessage.success("窗口添加成功");
    }

    windowDialogVisible.value = false;
    await loadCanteens();
  } catch (error) {
    if (error.name !== "ElMessageBoxCancel") {
      ElMessage.error(
        "保存失败：" + (error.response?.data?.message || error.message),
      );
    }
  }
};

// 删除窗口
const deleteWindow = async (id) => {
  try {
    await ElMessageBox.confirm("确定要删除这个窗口吗？", "确认删除", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    await windowApi.deleteWindow(id);
    ElMessage.success("窗口删除成功");
    await loadCanteens();
  } catch (error) {
    if (error.name !== "ElMessageBoxCancel") {
      ElMessage.error(
        "删除失败：" + (error.response?.data?.message || error.message),
      );
    }
  }
};

// 从菜品数据同步窗口
const syncWindowsFromDishes = async () => {
  try {
    await windowApi.syncWindowsFromDishes();
    ElMessage.success("窗口数据同步成功");
    await loadCanteens();
  } catch (error) {
    ElMessage.error(
      "同步失败：" + (error.response?.data?.message || error.message),
    );
  }
};

// 显示分配菜品对话框
const showAssignDishesDialog = async (window) => {
  selectedWindow.value = window;
  selectedDishes.value = [];
  searchKeyword.value = "";
  selectedCategory.value = "";

  // 加载所有菜品
  await loadAllDishes();

  assignDishesDialogVisible.value = true;
};

// 加载所有菜品
const loadAllDishes = async () => {
  try {
    loadingDishes.value = true;
    const response = await dishApi.getDishes();
    dishes.value = response.data || [];
    originalDishes.value = [...dishes.value];
    filteredDishes.value = [...dishes.value];

    // 提取所有菜系分类
    extractCategories();
  } catch (error) {
    ElMessage.error(
      "加载菜品失败：" + (error.response?.data?.message || error.message),
    );
    dishes.value = [];
    originalDishes.value = [];
    filteredDishes.value = [];
    categories.value = [];
  } finally {
    loadingDishes.value = false;
  }
};

// 提取菜系分类
const extractCategories = () => {
  const categorySet = new Set();
  dishes.value.forEach((dish) => {
    if (dish.windowName) {
      const category = dish.windowName.replace("窗口", "");
      categorySet.add(category);
    }
  });
  categories.value = Array.from(categorySet).sort();
};

// 处理搜索
const handleSearch = () => {
  if (!searchKeyword.value) {
    if (selectedCategory.value) {
      // 只有分类筛选
      filteredDishes.value = originalDishes.value.filter((dish) => {
        return (
          dish.windowName &&
          dish.windowName.replace("窗口", "") === selectedCategory.value
        );
      });
    } else {
      // 没有任何筛选
      filteredDishes.value = [...originalDishes.value];
    }
    return;
  }

  // 同时有搜索和分类筛选
  filteredDishes.value = originalDishes.value.filter((dish) => {
    const matchesSearch = dish.name
      .toLowerCase()
      .includes(searchKeyword.value.toLowerCase());
    const category = dish.windowName ? dish.windowName.replace("窗口", "") : "";
    const matchesCategory =
      !selectedCategory.value || category === selectedCategory.value;
    return matchesSearch && matchesCategory;
  });
};

// 处理分类筛选
const handleCategoryFilter = () => {
  if (!selectedCategory.value) {
    // 没有选择分类，显示所有菜品
    if (searchKeyword.value) {
      // 有搜索关键词
      filteredDishes.value = originalDishes.value.filter((dish) => {
        return dish.name
          .toLowerCase()
          .includes(searchKeyword.value.toLowerCase());
      });
    } else {
      // 没有搜索关键词
      filteredDishes.value = [...originalDishes.value];
    }
    return;
  }

  // 有分类筛选
  if (searchKeyword.value) {
    // 同时有搜索和分类筛选
    filteredDishes.value = originalDishes.value.filter((dish) => {
      return (
        dish.name.toLowerCase().includes(searchKeyword.value.toLowerCase()) &&
        dish.windowName &&
        dish.windowName.replace("窗口", "") === selectedCategory.value
      );
    });
  } else {
    // 只有分类筛选
    filteredDishes.value = originalDishes.value.filter((dish) => {
      return (
        dish.windowName &&
        dish.windowName.replace("窗口", "") === selectedCategory.value
      );
    });
  }
};

// 重置筛选
const resetFilters = () => {
  selectedCategory.value = "";
  searchKeyword.value = "";
  filteredDishes.value = [...originalDishes.value];
};

// 处理菜品选择变化
const handleDishSelectionChange = (selection) => {
  selectedDishes.value = selection;
};

// 分配菜品给窗口
const assignDishes = async () => {
  if (!selectedWindow.value || selectedDishes.value.length === 0) {
    ElMessage.warning("请选择菜品");
    return;
  }

  try {
    // 遍历选中的菜品，逐个分配到当前窗口
    for (const dish of selectedDishes.value) {
      await dishApi.updateDish(dish.id, {
        windowId: selectedWindow.value.id,
        windowName: selectedWindow.value.name,
        windowLocation: selectedWindow.value.location,
      });
    }

    ElMessage.success(
      `成功分配 ${selectedDishes.value.length} 个菜品到窗口 ${selectedWindow.value.name}`,
    );
    assignDishesDialogVisible.value = false;

    // 重新加载菜品列表，更新当前窗口信息
    await loadAllDishes();
  } catch (error) {
    ElMessage.error(
      "分配菜品失败：" + (error.response?.data?.message || error.message),
    );
  }
};

// 初始化
onMounted(async () => {
  await loadCanteens();
});
</script>

<style scoped>
.windows-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 28px;
  color: #333;
  margin-bottom: 10px;
}

.page-subtitle {
  font-size: 16px;
  color: #666;
}

.action-buttons {
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
}

.windows-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.canteens-windows {
  display: flex;
  gap: 20px;
}

.canteen-list {
  width: 300px;
  border-right: 1px solid #e6e6e6;
  padding-right: 20px;
}

.canteen-tree {
  max-height: 600px;
  overflow-y: auto;
}

.window-details {
  flex: 1;
  min-height: 600px;
  min-width: 0;
}

.no-selection {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
  color: #999;
}

.canteen-info {
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e6e6e6;
}

.canteen-info h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.tree-node {
  display: flex;
  align-items: center;
  gap: 8px;
}

.node-label {
  flex: 1;
}

.window-count {
  font-size: 12px;
  color: #999;
}

.operating-hours {
  font-size: 12px;
  color: #666;
}



.selected-canteen-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.selected-window-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.selected-window-info h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.selected-canteen-info h3 {
  margin: 0;
  font-size: 16px;
}

.window-detail-card {
  margin-top: 20px;
}

.window-detail-card .el-card__body {
  padding: 20px;
}

.window-detail-card .el-descriptions {
  margin-top: 20px;
}

.window-detail-card .el-descriptions__label {
  font-weight: bold;
  color: #333;
}

.window-detail-card .el-descriptions__content {
  color: #666;
}
</style>
