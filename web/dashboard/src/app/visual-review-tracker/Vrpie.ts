export class Vrpie {
  visual_review_instance_id: number;
  labels: string[];
  data: number[];

  constructor( visual_review_instance_id: number, labels: string[], data: number[]){
    this.visual_review_instance_id = visual_review_instance_id;
    this.labels = labels;
    this.data = data;
  }
}
