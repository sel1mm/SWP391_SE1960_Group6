package model;

public class Category {
    private int categoryId;
    private String categoryName;
    private String type;

    // --- Constructors ---
    public Category() {
    }

    public Category(int categoryId, String categoryName, String type) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.type = type;
    }

    public Category(String categoryName, String type) {
        this.categoryName = categoryName;
        this.type = type;
    }

    // --- Getters & Setters ---
    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    // --- toString() ---
    @Override
    public String toString() {
        return "Category{" +
                "categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", type='" + type + '\'' +
                '}';
    }
}
